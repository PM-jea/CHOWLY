// =========================================================
// CHOWLY — App logic
// Talks directly to Supabase (no custom backend server).
// =========================================================

// ---------- small helpers ----------
function genId(prefix) {
  return prefix + "-" + Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
}

function naira(amount) {
  return "₦" + Number(amount).toLocaleString("en-NG");
}

function showView(id) {
  document.querySelectorAll(".view").forEach((v) => v.classList.add("hidden"));
  document.getElementById(id).classList.remove("hidden");
  stopTrackingPoll();
  stopDashboardPoll();
  updateTableBanner();
}

// ---------- QR code table banner ----------
function updateTableBanner() {
  const banner = document.getElementById("table-banner");
  if (!banner) return;
  if (state.tableNumber && state.currentRestaurant) {
    banner.textContent = `Table ${state.tableNumber} · ${state.currentRestaurant.restaurant_name}`;
    banner.classList.remove("hidden");
  } else {
    banner.classList.add("hidden");
  }
}

function toast(message, isError = false) {
  const el = document.getElementById("toast");
  el.textContent = message;
  el.classList.toggle("error", isError);
  el.classList.remove("hidden");
  clearTimeout(toast._t);
  toast._t = setTimeout(() => el.classList.add("hidden"), 3200);
}

// ---------- app state ----------
const state = {
  restaurants: [],
  currentRestaurant: null,
  currentCustomer: null,
  cart: {}, // menu_item_id -> { item, qty }
  currentOrderId: null,
  waiter: null, // { restaurant_id, waiter_id, waiter_name }
  tableNumber: null, // set when the app is opened from a table's QR code
};

let trackingTimer = null;
let dashboardTimer = null;

function stopTrackingPoll() {
  if (trackingTimer) clearInterval(trackingTimer);
  trackingTimer = null;
}
function stopDashboardPoll() {
  if (dashboardTimer) clearInterval(dashboardTimer);
  dashboardTimer = null;
}

// =========================================================
// INIT
// =========================================================
document.addEventListener("DOMContentLoaded", init);

async function init() {
  wireRoleSwitch();
  wireBackLinks();
  wireIdentifyForm();
  wireCartSubmit();
  wireComplaintForm();
  wirePayButton();
  wireWaiterLoginForm();
  wireAssignModal();
  document.getElementById("refresh-status-btn").addEventListener("click", () => loadTracking(state.currentOrderId));
  document.getElementById("new-order-btn").addEventListener("click", () => {
    state.cart = {};
    showView("view-identify");
  });
  document.getElementById("waiter-refresh-btn").addEventListener("click", () => loadDashboard());

  await loadRestaurants();
  handleQrParams();
}

// =========================================================
// QR CODE HANDLING
// A table's QR code points to index.html?r=RESTAURANT_ID&t=TABLE_NUMBER
// Scanning it jumps straight past the restaurant picker and tags
// every order from that visit with the table number.
// =========================================================
function handleQrParams() {
  const params = new URLSearchParams(window.location.search);
  const restaurantId = params.get("r");
  const table = params.get("t");
  if (!restaurantId) return;

  const restaurant = state.restaurants.find((r) => r.restaurant_id === restaurantId);
  if (!restaurant) {
    toast("QR code restaurant was not recognized — pick your restaurant below.", true);
    return;
  }

  state.currentRestaurant = restaurant;
  state.tableNumber = table ? Number(table) : null;
  showView("view-identify");
}

// =========================================================
// ROLE SWITCH
// =========================================================
function wireRoleSwitch() {
  document.querySelectorAll(".role-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".role-btn").forEach((b) => {
        b.classList.remove("active");
        b.setAttribute("aria-selected", "false");
      });
      btn.classList.add("active");
      btn.setAttribute("aria-selected", "true");

      if (btn.dataset.role === "customer") {
        showView("view-choose-restaurant");
      } else {
        showView("view-waiter-login");
      }
    });
  });
}

function wireBackLinks() {
  document.querySelectorAll("[data-back]").forEach((btn) => {
    btn.addEventListener("click", () => showView(btn.dataset.back));
  });
}

// =========================================================
// RESTAURANTS (shared by customer + waiter flows)
// =========================================================
async function loadRestaurants() {
  const { data, error } = await supabaseClient.from("restaurant").select("*").order("restaurant_name");
  if (error) {
    toast("Could not load restaurants: " + error.message, true);
    return;
  }
  state.restaurants = data;
  renderRestaurantGrid(data);
  populateWaiterRestaurantSelect(data);
}

function renderRestaurantGrid(list) {
  const container = document.getElementById("restaurant-list");
  container.innerHTML = "";
  list.forEach((r) => {
    const card = document.createElement("button");
    card.className = "restaurant-card";
    card.innerHTML = `<h3>${r.restaurant_name}</h3><p class="muted">${r.restaurant_location}</p>`;
    card.addEventListener("click", () => {
      state.currentRestaurant = r;
      state.tableNumber = null; // manual pick, not from a table's QR code
      showView("view-identify");
    });
    container.appendChild(card);
  });
}

// =========================================================
// CUSTOMER: IDENTIFY
// =========================================================
function wireIdentifyForm() {
  document.getElementById("identify-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const name = document.getElementById("identify-name").value.trim();
    const phone = document.getElementById("identify-phone").value.trim();
    if (!name || !phone) return;

    // reuse an existing customer row if this phone has ordered before,
    // otherwise create a new one.
    const { data: existing } = await supabaseClient
      .from("customer")
      .select("*")
      .eq("customer_phone", phone)
      .maybeSingle();

    let customer = existing;
    if (!customer) {
      const { data: created, error } = await supabaseClient
        .from("customer")
        .insert({ customer_id: genId("C"), customer_name: name, customer_phone: phone })
        .select()
        .single();
      if (error) {
        toast("Could not save your details: " + error.message, true);
        return;
      }
      customer = created;
    }

    state.currentCustomer = customer;
    await loadMenu();
    showView("view-menu");
  });
}

// =========================================================
// CUSTOMER: MENU + CART
// =========================================================
async function loadMenu() {
  const r = state.currentRestaurant;
  document.getElementById("menu-restaurant-name").textContent = r.restaurant_name;
  document.getElementById("menu-restaurant-location").textContent = r.restaurant_location;

  const { data, error } = await supabaseClient
    .from("menu")
    .select("*, menu_item(*)")
    .eq("restaurant_id", r.restaurant_id);

  if (error) {
    toast("Could not load the menu: " + error.message, true);
    return;
  }

  state.cart = {};
  renderMenu(data);
  updateCartUI();
}

function renderMenu(menus) {
  const container = document.getElementById("menu-list");
  container.innerHTML = "";

  menus.forEach((menu) => {
    const heading = document.createElement("div");
    heading.className = "menu-category";
    heading.textContent = menu.menu_type + (menu.menu_description ? " — " + menu.menu_description : "");
    container.appendChild(heading);

    (menu.menu_item || []).forEach((item) => {
      const row = document.createElement("div");
      row.className = "menu-item-row";
      row.innerHTML = `
        <div class="menu-item-info">
          <h4>${item.item_name}</h4>
          <p class="menu-item-desc">${item.item_description || ""}</p>
          <p class="menu-item-meta">~${item.prep_time_minutes} min</p>
        </div>
        <div class="menu-item-action">
          <span class="menu-item-price">${naira(item.item_price)}</span>
          <button class="qty-btn" data-action="minus" data-id="${item.menu_item_id}">&minus;</button>
          <span class="qty-value" id="qty-${item.menu_item_id}">0</span>
          <button class="qty-btn" data-action="plus" data-id="${item.menu_item_id}">+</button>
        </div>
      `;
      container.appendChild(row);

      row.querySelector('[data-action="plus"]').addEventListener("click", () => changeQty(item, 1));
      row.querySelector('[data-action="minus"]').addEventListener("click", () => changeQty(item, -1));
    });
  });
}

function changeQty(item, delta) {
  const line = state.cart[item.menu_item_id] || { item, qty: 0 };
  line.qty = Math.max(0, line.qty + delta);
  if (line.qty === 0) {
    delete state.cart[item.menu_item_id];
  } else {
    state.cart[item.menu_item_id] = line;
  }
  const qtyEl = document.getElementById("qty-" + item.menu_item_id);
  if (qtyEl) qtyEl.textContent = line.qty || 0;
  updateCartUI();
}

function updateCartUI() {
  const linesEl = document.getElementById("cart-items");
  const lines = Object.values(state.cart);
  let total = 0;

  if (lines.length === 0) {
    linesEl.innerHTML = '<p class="cart-empty">Nothing added yet — tap "+" on any item.</p>';
  } else {
    linesEl.innerHTML = lines
      .map((l) => {
        const subtotal = l.item.item_price * l.qty;
        total += subtotal;
        return `<div class="cart-line"><span>${l.qty} × ${l.item.item_name}</span><span>${naira(subtotal)}</span></div>`;
      })
      .join("");
  }

  document.getElementById("cart-total").textContent = naira(total);
  document.getElementById("submit-order-btn").disabled = lines.length === 0;
}

function wireCartSubmit() {
  document.getElementById("submit-order-btn").addEventListener("click", async () => {
    const lines = Object.values(state.cart);
    if (lines.length === 0) return;

    const waitingTime = Math.max(...lines.map((l) => l.item.prep_time_minutes));

    const { data: order, error: orderErr } = await supabaseClient
      .from("order")
      .insert({
        customer_id: state.currentCustomer.customer_id,
        restaurant_id: state.currentRestaurant.restaurant_id,
        order_status: "Placed",
        waiting_time_minutes: waitingTime,
        table_number: state.tableNumber,
      })
      .select()
      .single();

    if (orderErr) {
      toast("Could not place order: " + orderErr.message, true);
      return;
    }

    const orderItems = lines.map((l) => ({
      order_id: order.order_id,
      menu_item_id: l.item.menu_item_id,
      quantity: l.qty,
      subtotal: l.item.item_price * l.qty,
    }));

    const { error: itemsErr } = await supabaseClient.from("order_item").insert(orderItems);
    if (itemsErr) {
      toast("Order created but items failed to save: " + itemsErr.message, true);
      return;
    }

    state.currentOrderId = order.order_id;
    showView("view-tracking");
    await loadTracking(order.order_id);
    trackingTimer = setInterval(() => loadTracking(order.order_id), 8000);
  });
}

// =========================================================
// CUSTOMER: ORDER TRACKING
// =========================================================
async function loadTracking(orderId) {
  const { data: order, error } = await supabaseClient
    .from("order")
    .select("*, waiter(*), chef(*), bartender(*), order_item(*, menu_item(*))")
    .eq("order_id", orderId)
    .single();

  if (error) {
    toast("Could not refresh order: " + error.message, true);
    return;
  }

  document.getElementById("track-order-id").textContent = order.order_id;
  document.getElementById("track-wait").textContent = order.waiting_time_minutes;

  const statusEl = document.getElementById("track-status");
  statusEl.textContent = order.order_status;
  statusEl.classList.toggle("served", order.order_status === "Served");

  let total = 0;
  document.getElementById("track-items").innerHTML = order.order_item
    .map((oi) => {
      total += Number(oi.subtotal);
      return `<li><span>${oi.quantity} × ${oi.menu_item.item_name}</span><span>${naira(oi.subtotal)}</span></li>`;
    })
    .join("");
  document.getElementById("track-total").textContent = naira(total);

  const staffBits = [];
  if (order.waiter) staffBits.push("Waiter: " + order.waiter.waiter_name);
  if (order.chef) staffBits.push("Chef: " + order.chef.chef_name);
  if (order.bartender) staffBits.push("Bartender: " + order.bartender.bartender_name);
  document.getElementById("track-staff").textContent = staffBits.length
    ? staffBits.join(" · ")
    : "Waiting for a waiter to pick up your order...";

  // payment only offered once the order has been served
  const payBox = document.getElementById("payment-box");
  const { data: existingPayment } = await supabaseClient
    .from("payment")
    .select("*")
    .eq("order_id", orderId)
    .maybeSingle();

  if (order.order_status !== "Served") {
    payBox.querySelector("#payment-pending").classList.add("hidden");
    payBox.querySelector("#payment-done").classList.add("hidden");
    payBox.querySelector(".demo-flag").textContent = "Payment unlocks once your order has been served.";
  } else if (existingPayment) {
    payBox.querySelector("#payment-pending").classList.add("hidden");
    payBox.querySelector("#payment-done").classList.remove("hidden");
  } else {
    payBox.dataset.total = total;
    payBox.querySelector(".demo-flag").textContent = "Demo payment only — no real money is charged.";
    payBox.querySelector("#payment-pending").classList.remove("hidden");
  }
}

// =========================================================
// CUSTOMER: COMPLAINT
// =========================================================
function wireComplaintForm() {
  document.getElementById("complaint-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const desc = document.getElementById("complaint-desc").value.trim();
    const rating = document.getElementById("complaint-rating").value;
    if (!desc || !rating) return;

    const { error } = await supabaseClient.from("complaint").insert({
      order_id: state.currentOrderId,
      customer_id: state.currentCustomer.customer_id,
      complaint_desc: desc,
      rating: Number(rating),
    });

    if (error) {
      toast("Could not submit complaint: " + error.message, true);
      return;
    }

    document.getElementById("complaint-form").classList.add("hidden");
    document.getElementById("complaint-confirm").classList.remove("hidden");
  });
}

// =========================================================
// CUSTOMER: PAYMENT (demo only)
// =========================================================
function wirePayButton() {
  document.getElementById("pay-btn").addEventListener("click", async () => {
    const payBox = document.getElementById("payment-box");
    const total = Number(payBox.dataset.total || 0);
    const method = document.getElementById("payment-method").value;

    const { error } = await supabaseClient.from("payment").insert({
      order_id: state.currentOrderId,
      payment_amount: total,
      payment_method: method,
      payment_status: "Paid",
    });

    if (error) {
      toast("Payment could not be recorded: " + error.message, true);
      return;
    }

    payBox.querySelector("#payment-pending").classList.add("hidden");
    payBox.querySelector("#payment-done").classList.remove("hidden");
    toast("Demo payment recorded.");
  });
}

// =========================================================
// WAITER: LOGIN (restaurant + name, no password)
// =========================================================
function populateWaiterRestaurantSelect(restaurants) {
  const sel = document.getElementById("waiter-restaurant");
  sel.innerHTML = restaurants
    .map((r) => `<option value="${r.restaurant_id}">${r.restaurant_name}</option>`)
    .join("");
  sel.addEventListener("change", () => populateWaiterNameSelect(sel.value));
  if (restaurants.length) populateWaiterNameSelect(restaurants[0].restaurant_id);
}

async function populateWaiterNameSelect(restaurantId) {
  const { data, error } = await supabaseClient.from("waiter").select("*").eq("restaurant_id", restaurantId);
  const sel = document.getElementById("waiter-name");
  if (error || !data) {
    sel.innerHTML = "";
    return;
  }
  sel.innerHTML = data.map((w) => `<option value="${w.waiter_id}">${w.waiter_name}</option>`).join("");
}

function wireWaiterLoginForm() {
  document.getElementById("waiter-login-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const restaurantId = document.getElementById("waiter-restaurant").value;
    const waiterId = document.getElementById("waiter-name").value;
    const restaurant = state.restaurants.find((r) => r.restaurant_id === restaurantId);
    const waiterName = document.getElementById("waiter-name").selectedOptions[0].textContent;

    state.waiter = { restaurant_id: restaurantId, waiter_id: waiterId, waiter_name: waiterName };
    document.getElementById("waiter-dash-restaurant").textContent = restaurant.restaurant_name;
    document.getElementById("waiter-dash-name").textContent = waiterName;

    showView("view-waiter-dashboard");
    await loadDashboard();
    dashboardTimer = setInterval(loadDashboard, 10000);
  });
}

// =========================================================
// WAITER: DASHBOARD
// =========================================================
async function loadDashboard() {
  if (!state.waiter) return;
  const { data, error } = await supabaseClient
    .from("order")
    .select("*, customer(*), waiter(*), chef(*), bartender(*), order_item(*, menu_item(*))")
    .eq("restaurant_id", state.waiter.restaurant_id)
    .order("order_date", { ascending: true });

  if (error) {
    toast("Could not load orders: " + error.message, true);
    return;
  }

  const unclaimed = data.filter((o) => o.order_status === "Placed");
  const preparing = data.filter((o) => o.order_status === "Preparing");
  const served = data.filter((o) => o.order_status === "Served").slice(-10).reverse();

  renderOrderColumn("rail-unclaimed", unclaimed, "unclaimed");
  renderOrderColumn("rail-mine", preparing, "preparing");
  renderOrderColumn("rail-served", served, "served");
}

function orderItemsSummary(order) {
  return order.order_item.map((oi) => `${oi.quantity}× ${oi.menu_item.item_name}`).join(", ");
}

function renderOrderColumn(containerId, orders, kind) {
  const container = document.getElementById(containerId);
  if (orders.length === 0) {
    container.innerHTML = '<p class="muted">Nothing here right now.</p>';
    return;
  }

  container.innerHTML = "";
  orders.forEach((order) => {
    const card = document.createElement("div");
    card.className = "order-card " + kind;
    const total = order.order_item.reduce((sum, oi) => sum + Number(oi.subtotal), 0);
    card.innerHTML = `
      <h4>Order #${order.order_id} — ${order.customer.customer_name}${
        order.table_number ? " · Table " + order.table_number : ""
      }</h4>
      <div class="order-meta">${orderItemsSummary(order)}</div>
      <div class="order-meta">${naira(total)} · waiting ${order.waiting_time_minutes} min</div>
      ${
        kind === "preparing"
          ? `<div class="order-meta">Chef: ${order.chef ? order.chef.chef_name : "—"} · Bartender: ${
              order.bartender ? order.bartender.bartender_name : "—"
            }</div>`
          : ""
      }
    `;

    if (kind === "unclaimed") {
      const btn = document.createElement("button");
      btn.className = "btn-primary";
      btn.textContent = "Open & assign";
      btn.addEventListener("click", () => openAssignModal(order));
      card.appendChild(btn);
    }

    if (kind === "preparing") {
      const btn = document.createElement("button");
      btn.className = "btn-secondary";
      btn.textContent = "Mark as served";
      btn.addEventListener("click", () => markServed(order.order_id));
      card.appendChild(btn);
    }

    container.appendChild(card);
  });
}

async function markServed(orderId) {
  const { error } = await supabaseClient.from("order").update({ order_status: "Served" }).eq("order_id", orderId);
  if (error) {
    toast("Could not update order: " + error.message, true);
    return;
  }
  toast("Order #" + orderId + " marked as served.");
  loadDashboard();
}

// =========================================================
// WAITER: ASSIGN MODAL
// =========================================================
let assignTarget = null;

function wireAssignModal() {
  document.getElementById("assign-modal-close").addEventListener("click", closeAssignModal);
  document.getElementById("assign-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const chefId = document.getElementById("assign-chef").value;
    const bartenderId = document.getElementById("assign-bartender").value;

    const { error } = await supabaseClient
      .from("order")
      .update({
        waiter_id: state.waiter.waiter_id,
        chef_id: chefId,
        bartender_id: bartenderId,
        order_status: "Preparing",
      })
      .eq("order_id", assignTarget.order_id);

    if (error) {
      toast("Could not assign order: " + error.message, true);
      return;
    }

    closeAssignModal();
    toast("Order #" + assignTarget.order_id + " is now preparing.");
    loadDashboard();
  });
}

async function openAssignModal(order) {
  assignTarget = order;
  document.getElementById("assign-order-id").textContent = order.order_id;
  document.getElementById("assign-items").innerHTML = order.order_item
    .map((oi) => `<li><span>${oi.quantity} × ${oi.menu_item.item_name}</span><span>${naira(oi.subtotal)}</span></li>`)
    .join("");

  const [{ data: chefs }, { data: bartenders }] = await Promise.all([
    supabaseClient.from("chef").select("*").eq("restaurant_id", state.waiter.restaurant_id),
    supabaseClient.from("bartender").select("*").eq("restaurant_id", state.waiter.restaurant_id),
  ]);

  document.getElementById("assign-chef").innerHTML = (chefs || [])
    .map((c) => `<option value="${c.chef_id}">${c.chef_name} (${c.chef_specialty})</option>`)
    .join("");
  document.getElementById("assign-bartender").innerHTML = (bartenders || [])
    .map((b) => `<option value="${b.bartender_id}">${b.bartender_name} (${b.bartender_specialty})</option>`)
    .join("");

  document.getElementById("assign-modal").classList.remove("hidden");
}

function closeAssignModal() {
  document.getElementById("assign-modal").classList.add("hidden");
  assignTarget = null;
}
