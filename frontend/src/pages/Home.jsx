import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import AlternativeCard from '../components/AlternativeCard';
import Loading from '../components/Loading';
import { getLatestAlternatives } from '../services/alternativeService';

const Home = () => {
  const [alternatives, setAlternatives] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchAlternatives = async () => {
      try {
        const data = await getLatestAlternatives();
        setAlternatives(data);
        setLoading(false);
      } catch (err) {
        setError('Fehler beim Laden der Alternativen.');
        setLoading(false);
      }
    };

    fetchAlternatives();
  }, []);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Willkommen bei FreeWorldFirst Collector</h1>
        <p className="text-xl text-gray-600 max-w-3xl mx-auto">
          Entdecken Sie ethische Alternativen zu gängigen BigTech-Produkten und -Diensten. 
          Gemeinsam für mehr digitale Souveränität.
        </p>
      </div>
      
      <div className="bg-primary-50 rounded-xl p-8 mb-12">
        <div className="flex flex-col md:flex-row items-center">
          <div className="md:w-2/3 mb-6 md:mb-0 md:pr-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Ethische Alternativen vorschlagen</h2>
            <p className="text-gray-600 mb-4">
              Kennen Sie eine bessere, ethischere Alternative zu einem BigTech-Produkt?
              Teilen Sie Ihr Wissen mit der Community und helfen Sie anderen, 
              bewusstere Entscheidungen zu treffen.
            </p>
            <Link to="/alternatives/new" className="btn-primary inline-block">
              Alternative vorschlagen
            </Link>
          </div>
          <div className="md:w-1/3">
            <img 
              src="/illustration-suggestion.svg" 
              alt="Illustration" 
              className="w-full h-auto"
            />
          </div>
        </div>
      </div>
      
      <div className="mb-12">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-900">Neueste Alternativen</h2>
          <Link to="/alternatives" className="text-primary-600 hover:text-primary-700">
            Alle anzeigen &rarr;
          </Link>
        </div>
        
        {loading ? (
          <Loading />
        ) : error ? (
          <div className="bg-red-50 p-4 rounded text-red-800">{error}</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {alternatives.map((alternative) => (
              <AlternativeCard key={alternative.id} alternative={alternative} />
            ))}
          </div>
        )}
      </div>
      
      <div className="bg-gray-50 rounded-xl p-8">
        <h2 className="text-2xl font-bold text-gray-900 mb-4 text-center">Wie es funktioniert</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-6">
          <div className="text-center">
            <div className="bg-primary-100 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-primary-600 font-bold">1</span>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Vorschlagen</h3>
            <p className="text-gray-600">
              Schlagen Sie ethische Alternativen zu BigTech-Produkten vor und 
              erklären Sie die Vorteile.
            </p>
          </div>
          <div className="text-center">
            <div className="bg-primary-100 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-primary-600 font-bold">2</span>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Abstimmen</h3>
            <p className="text-gray-600">
              Stimmen Sie für die besten Alternativen ab und helfen Sie anderen, 
              fundierte Entscheidungen zu treffen.
            </p>
          </div>
          <div className="text-center">
            <div className="bg-primary-100 w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-primary-600 font-bold">3</span>
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Diskutieren</h3>
            <p className="text-gray-600">
              Teilen Sie Ihre Erfahrungen und diskutieren Sie mit der Community 
              über die Vor- und Nachteile.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;
