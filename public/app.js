const input = document.getElementById('search-input');
const analyticsList = document.getElementById('analytics-list');

let timeout;

input.addEventListener('input', () => {
  clearTimeout(timeout);
  timeout = setTimeout(() => {
    const query = input.value.trim();
    if (query.length >= 3) {
      sendSearch(query);
    }
  }, 2000);
});

function sendSearch(query) {
  fetch('/searches', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ query })
  })
    .catch(error => console.error('Error while sending the search:', error));
}

function fetchAnalytics() {
  fetch('/analytics')
    .then(res => {
      if (!res.ok) throw new Error('Network error');
      return res.json();
    })
    .then(data => {
      renderAnalytics(data);
    })
    .catch(error => {
      console.error('Error while fetching analytics:', error);
      analyticsList.innerHTML = '<li class="text-red-500">Error loading analytics</li>';
    });
}

function renderAnalytics(data) {
  analyticsList.innerHTML = '';
  if (Object.keys(data).length === 0) {
    analyticsList.innerHTML = '<li class="text-gray-500">No searches recorded at the moment</li>';
    return;
  }
  for (const [query] of Object.entries(data)) {
    const li = document.createElement('li');
    li.textContent = `${query}`;
    li.className = 'p-2 bg-white rounded shadow hover:bg-gray-50';
    analyticsList.appendChild(li);
  }
}

fetchAnalytics();
setInterval(fetchAnalytics, 2000);
