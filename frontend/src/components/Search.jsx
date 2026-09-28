import "./Search.css"
import { useState } from "react";

function Search() {
  const [query, setQuery] = useState("");

  function handleSearch() {
    console.log("Searching for:", query);
  }

  return (
    <div className="search">
      <h2>Search</h2>

      <input
        type="text"
        placeholder="Search..."
        value={query}
        onChange={event => setQuery(event.target.value)}
      />

      <button onClick={handleSearch}>
        Search
      </button>
    </div>
  );
}

export default Search;