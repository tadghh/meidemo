// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("turbo:load", () => {
  const SEARCH_DELAY = 300; // In miliseconds
  const searchInput = document.getElementById('searchinput');
  const resultsContainer = document.getElementById('hits');
  const progressBar = document.getElementById('progress-bar');
  let debounceTimeout;

  // Function to fetch search results
  const fetchSearchResults = (query) => {
    // If no search bail, you should check the Meilisearch docs they cover the default behaviour of when given an empty search
    if (!query) {
      return;
    }

    fetch(`/search.json?query=${query}`)
      .then(response => response.json())
      .then(data => {
        // Create posts and add them all at once, less updates to the DOM
        resultsContainer.innerHTML = data.length ?
          data.map(post => createListItem(post)).join('') :
          '<li>No results found.</li>';
      })
      .catch(error => {
        console.error('Error fetching search results:', error);
        resultsContainer.innerHTML = '<li>Error fetching results.</li>';
      });
  };

  // Function to create list item
  const createListItem = (search_result) => {
    // We got a title field so it must be a post
    if (search_result.title) {
      // We are checking what type of values were returned by the controller
      // if the object has a title field we know its a post
      return `<li>
			<p>Post: ${search_result.title}</p>
      <p class="text-sm text-neutral-200">${search_result.content.slice(0, 70)}</p>
      </li>`;
    }
    return `<li>
			<p>Community: ${search_result.name}</p>
      <p class="text-sm text-neutral-200">${search_result.description.slice(0, 70)}</p>
      </li>`;
  };

  // Animation - Search input delay, not everyone types fast
  const debounce = (func, delay) => {
    return (...args) => {
      clearTimeout(debounceTimeout);
      progressBar.style.transition = 'none';
      progressBar.style.width = '0';  // Reset progress bar
      progressBar.style.opacity = '1'; // Reset opacity

      // Start the progress bar animation
      setTimeout(() => {
        progressBar.style.transition = `width ${delay}ms linear, opacity 0.3s ease-in`;
        progressBar.style.width = '100%';  // Slide to 100%
      }, 10);  // Small delay to ensure the CSS transition works

      debounceTimeout = setTimeout(() => {
        func(...args);  // Execute the search, we are 'consuming ourself' here, Goto fig: 1

        progressBar.style.opacity = '0';
        setTimeout(() => {
          progressBar.style.width = '0';
        }, SEARCH_DELAY);
      }, delay);
    };
  };

  // Event listener for input changes (search as you type) with debounce
  searchInput.addEventListener('input', debounce((event) => {
    fetchSearchResults(event.target.value); // fig: 1
  }, SEARCH_DELAY));  // Adjust the delay (e.g., 300ms)
});
