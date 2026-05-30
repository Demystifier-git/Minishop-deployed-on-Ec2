const API_BASE = "https://api.delightdavid.online";

async function loadProducts() {
  const res = await fetch(`${API_BASE}/products/`);
  const data = await res.json();

  const list = document.getElementById("products");
  list.innerHTML = "";

  data.forEach(p => {
    const li = document.createElement("li");
    li.innerText = `${p.name} - $${p.price}`;
    list.appendChild(li);
  });
}

async function addProduct() {
  const name = document.getElementById("name").value;
  const price = parseFloat(document.getElementById("price").value);

  await fetch(`${API_BASE}/products/`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ name, price })
  });

  loadProducts();
}

window.onload = loadProducts;