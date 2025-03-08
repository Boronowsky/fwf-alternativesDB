import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import AlternativeCard from '../components/AlternativeCard';
import Loading from '../components/Loading';
import Button from '../components/Button';
import { getAlternatives } from '../services/alternativeService';

const Alternatives = () => {
  const [alternatives, setAlternatives] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filter, setFilter] = useState('');
  const [category, setCategory] = useState('');

  useEffect(() => {
    const fetchAlternatives = async () => {
      try {
        setLoading(true);
        const response = await getAlternatives({ 
          page, 
          search: filter,
          category: category
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
  }, [page, filter, category]);

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

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="flex flex-col md:flex-row justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-4 md:mb-0">Ethische Alternativen</h1>
        <Link to="/alternatives/new" className="btn-primary">
          Alternative vorschlagen
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow p-6 mb-8">
        <h2 className="text-lg font-medium text-gray-900 mb-4">Filter</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-1">
              Suche
            </label>
            <input
              type="text"
              id="search"
              value={filter}
              onChange={handleSearchChange}
              placeholder="Nach Titel oder ersetztem Produkt suchen..."
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
              <option value="Suchmaschine">Suchmaschine</option>
              <option value="E-Mail">E-Mail</option>
              <option value="Cloud-Speicher">Cloud-Speicher</option>
              <option value="Browser">Browser</option>
              <option value="Messenger">Messenger</option>
              <option value="Social Media">Social Media</option>
              <option value="Betriebssystem">Betriebssystem</option>
              <option value="Office Suite">Office Suite</option>
              <option value="Videokonferenz">Videokonferenz</option>
              <option value="Streaming">Streaming</option>
            </select>
          </div>
        </div>
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
              <AlternativeCard key={alternative.id} alternative={alternative} />
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
