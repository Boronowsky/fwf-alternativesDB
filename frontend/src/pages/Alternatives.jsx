import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import AlternativeCard from '../components/AlternativeCard';
import Loading from '../components/Loading';
import Button from '../components/Button';
import { getAlternatives } from '../services/alternativeService';
import { getAllTags } from '../services/tagService';
import { addBookmark, removeBookmark } from '../services/bookmarkService';

const Alternatives = () => {
  const [alternatives, setAlternatives] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filter, setFilter] = useState('');
  const [category, setCategory] = useState('');
  const [tags, setTags] = useState([]);
  const [selectedTags, setSelectedTags] = useState([]);
  const [sortBy, setSortBy] = useState('createdAt');
  const [sortOrder, setSortOrder] = useState('DESC');

  useEffect(() => {
    const fetchTags = async () => {
      try {
        const tagsData = await getAllTags();
        setTags(tagsData);
      } catch (err) {
        console.error('Fehler beim Laden der Tags:', err);
      }
    };
    fetchTags();
  }, []);

  useEffect(() => {
    const fetchAlternatives = async () => {
      try {
        setLoading(true);
        const response = await getAlternatives({
          page,
          search: filter,
          category: category,
          tags: selectedTags.join(','),
          sortBy,
          sortOrder
        });
        setAlternatives(response.alternatives);
        setTotalPages(response.pages);
        setLoading(false);
      } catch (err) {
        setError('Fehler beim Laden der Alternativen.');
        setLoading(false);
      }
    };

    fetchAlternatives();
  }, [page, filter, category, selectedTags, sortBy, sortOrder]);

  const handleNextPage = () => {
    if (page < totalPages) {
      setPage(page + 1);
      window.scrollTo(0, 0);
    }
  };

  const handlePreviousPage = () => {
    if (page > 1) {
      setPage(page - 1);
      window.scrollTo(0, 0);
    }
  };

  const handleSearchChange = (e) => {
    setFilter(e.target.value);
    setPage(1);
  };

  const handleCategoryChange = (e) => {
    setCategory(e.target.value);
    setPage(1);
  };

  const handleTagToggle = (tagId) => {
    setSelectedTags(prev =>
      prev.includes(tagId)
        ? prev.filter(id => id !== tagId)
        : [...prev, tagId]
    );
    setPage(1);
  };

  const handleSortChange = (e) => {
    setSortBy(e.target.value);
    setPage(1);
  };

  const handleSortOrderToggle = () => {
    setSortOrder(prev => prev === 'ASC' ? 'DESC' : 'ASC');
    setPage(1);
  };

  const handleBookmarkToggle = async (alternativeId, shouldBookmark) => {
    try {
      if (shouldBookmark) {
        await addBookmark(alternativeId);
      } else {
        await removeBookmark(alternativeId);
      }
    } catch (err) {
      console.error('Bookmark-Fehler:', err);
      throw err;
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="flex flex-col md:flex-row justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-4 md:mb-0">Ethische Alternativen</h1>
        <Link to="/alternatives/new" className="btn-primary">
          Alternative vorschlagen
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow p-6 mb-8">
        <h2 className="text-lg font-medium text-gray-900 mb-4">Filter & Sortierung</h2>

        {/* Suche und Kategorie */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div>
            <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-1">
              Suche
            </label>
            <input
              type="text"
              id="search"
              value={filter}
              onChange={handleSearchChange}
              placeholder="Nach Titel suchen..."
              className="input-field"
            />
          </div>
          <div>
            <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-1">
              Kategorie
            </label>
            <select
              id="category"
              value={category}
              onChange={handleCategoryChange}
              className="input-field"
            >
              <option value="">Alle Kategorien</option>
              <option value="Messaging">Messaging</option>
              <option value="Cloud Storage">Cloud Storage</option>
              <option value="Browser">Browser</option>
              <option value="Suchmaschine">Suchmaschine</option>
              <option value="Social Media">Social Media</option>
              <option value="Passwort-Manager">Passwort-Manager</option>
            </select>
          </div>
          <div>
            <label htmlFor="sortBy" className="block text-sm font-medium text-gray-700 mb-1">
              Sortieren nach
            </label>
            <div className="flex gap-2">
              <select
                id="sortBy"
                value={sortBy}
                onChange={handleSortChange}
                className="input-field flex-1"
              >
                <option value="createdAt">Neueste</option>
                <option value="upvotes">Beliebteste</option>
                <option value="title">Titel</option>
              </select>
              <button
                onClick={handleSortOrderToggle}
                className="px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
                title={sortOrder === 'ASC' ? 'Aufsteigend' : 'Absteigend'}
              >
                {sortOrder === 'ASC' ? '↑' : '↓'}
              </button>
            </div>
          </div>
        </div>

        {/* Tags */}
        {tags.length > 0 && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tags filtern
            </label>
            <div className="flex flex-wrap gap-2">
              {tags.map((tag) => (
                <button
                  key={tag.id}
                  onClick={() => handleTagToggle(tag.id)}
                  className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium transition-all ${
                    selectedTags.includes(tag.id)
                      ? 'ring-2 ring-offset-2'
                      : 'opacity-60 hover:opacity-100'
                  }`}
                  style={{
                    backgroundColor: `${tag.color}20`,
                    color: tag.color,
                    ringColor: tag.color
                  }}
                >
                  {tag.name}
                  {selectedTags.includes(tag.id) && ' ✓'}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>

      {loading ? (
        <Loading />
      ) : error ? (
        <div className="bg-red-50 p-4 rounded text-red-800">{error}</div>
      ) : alternatives.length === 0 ? (
        <div className="text-center py-10">
          <p className="text-gray-500 mb-4">Keine Alternativen gefunden.</p>
          <Link to="/alternatives/new" className="btn-primary">
            Erste Alternative vorschlagen
          </Link>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            {alternatives.map((alternative) => (
              <AlternativeCard
                key={alternative.id}
                alternative={alternative}
                onBookmarkToggle={handleBookmarkToggle}
              />
            ))}
          </div>

          <div className="flex justify-between items-center">
            <Button
              variant="secondary"
              onClick={handlePreviousPage}
              disabled={page === 1}
            >
              Vorherige Seite
            </Button>
            <span className="text-sm text-gray-600">
              Seite {page} von {totalPages}
            </span>
            <Button
              variant="secondary"
              onClick={handleNextPage}
              disabled={page === totalPages}
            >
              Nächste Seite
            </Button>
          </div>
        </>
      )}
    </div>
  );
};

export default Alternatives;
