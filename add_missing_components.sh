#!/bin/bash
# add_missing_components.sh - Ergänzt fehlende Frontend-Komponenten

set -e  # Skript beenden, wenn ein Befehl fehlschlägt

# Farbcodes für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Hilfsfunktionen
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Erstelle die Alternativen-Seite
create_alternatives_page() {
    log_info "Erstelle Alternativen-Seite..."
    
    cat > frontend/src/pages/Alternatives.jsx << EOL
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
EOL

    log_info "Alternativen-Seite wurde erstellt."
}

# 2. Erstelle die Detailseite für eine Alternative
create_alternative_detail_page() {
    log_info "Erstelle Detailseite für Alternativen..."
    
    cat > frontend/src/pages/AlternativeDetail.jsx << EOL
import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';
import Loading from '../components/Loading';
import Button from '../components/Button';
import TextArea from '../components/TextArea';
import { getAlternativeById, upvoteAlternative, downvoteAlternative, addComment, getComments } from '../services/alternativeService';

const AlternativeDetail = () => {
  const { id } = useParams();
  const { user, isAuthenticated } = useContext(AuthContext);
  const navigate = useNavigate();
  
  const [alternative, setAlternative] = useState(null);
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState('');
  const [loading, setLoading] = useState(true);
  const [commentLoading, setCommentLoading] = useState(false);
  const [error, setError] = useState(null);
  const [voteLoading, setVoteLoading] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await getAlternativeById(id);
        setAlternative(data);
        
        const commentsData = await getComments(id);
        setComments(commentsData);
        
        setLoading(false);
      } catch (err) {
        setError('Fehler beim Laden der Alternative.');
        setLoading(false);
      }
    };

    fetchData();
  }, [id]);

  const handleUpvote = async () => {
    if (!isAuthenticated) {
      navigate('/login', { state: { from: \`/alternatives/\${id}\` } });
      return;
    }

    try {
      setVoteLoading(true);
      const response = await upvoteAlternative(id);
      setAlternative({
        ...alternative,
        upvotes: response.upvotes
      });
      setVoteLoading(false);
    } catch (err) {
      setError('Fehler bei der Abstimmung.');
      setVoteLoading(false);
    }
  };

  const handleDownvote = async () => {
    if (!isAuthenticated) {
      navigate('/login', { state: { from: \`/alternatives/\${id}\` } });
      return;
    }

    try {
      setVoteLoading(true);
      const response = await downvoteAlternative(id);
      setAlternative({
        ...alternative,
        upvotes: response.upvotes
      });
      setVoteLoading(false);
    } catch (err) {
      setError('Fehler bei der Abstimmung.');
      setVoteLoading(false);
    }
  };

  const handleCommentSubmit = async (e) => {
    e.preventDefault();
    
    if (!isAuthenticated) {
      navigate('/login', { state: { from: \`/alternatives/\${id}\` } });
      return;
    }

    if (!newComment.trim()) return;

    try {
      setCommentLoading(true);
      const comment = await addComment(id, newComment);
      setComments([comment, ...comments]);
      setNewComment('');
      setCommentLoading(false);
    } catch (err) {
      setError('Fehler beim Hinzufügen des Kommentars.');
      setCommentLoading(false);
    }
  };

  if (loading) return <div className="max-w-7xl mx-auto px-4 py-8"><Loading /></div>;
  if (error) return <div className="max-w-7xl mx-auto px-4 py-8 bg-red-50 p-4 rounded text-red-800">{error}</div>;
  if (!alternative) return <div className="max-w-7xl mx-auto px-4 py-8">Alternative nicht gefunden.</div>;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <Link to="/alternatives" className="text-primary-600 hover:text-primary-800 flex items-center mb-6">
        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
          <path fillRule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clipRule="evenodd" />
        </svg>
        Zurück zu allen Alternativen
      </Link>

      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="p-6 md:p-8">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">{alternative.title}</h1>
              <p className="text-gray-600 mt-2">Ersetzt: <span className="font-medium">{alternative.replaces}</span></p>
            </div>
            <div className="mt-4 md:mt-0 flex items-center">
              <span className="bg-primary-100 text-primary-800 text-sm px-3 py-1 rounded-full">
                {alternative.category}
              </span>
              <a 
                href={alternative.website} 
                target="_blank" 
                rel="noopener noreferrer" 
                className="ml-4 text-primary-600 hover:text-primary-800 flex items-center"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M12.586 4.586a2 2 0 112.828 2.828l-3 3a2 2 0 01-2.828 0 1 1 0 00-1.414 1.414 4 4 0 005.656 0l3-3a4 4 0 00-5.656-5.656l-1.5 1.5a1 1 0 101.414 1.414l1.5-1.5zm-5 5a2 2 0 012.828 0 1 1 0 101.414-1.414 4 4 0 00-5.656 0l-3 3a4 4 0 105.656 5.656l1.5-1.5a1 1 0 10-1.414-1.414l-1.5 1.5a2 2 0 11-2.828-2.828l3-3z" clipRule="evenodd" />
                </svg>
                Website
              </a>
            </div>
          </div>

          <div className="flex items-center space-x-4 mb-8">
            <div className="flex items-center">
              <button 
                onClick={handleUpvote} 
                disabled={voteLoading}
                className="text-gray-400 hover:text-green-500 disabled:opacity-50"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 15l7-7 7 7" />
                </svg>
              </button>
              <span className="text-lg font-medium mx-2">{alternative.upvotes}</span>
              <button 
                onClick={handleDownvote} 
                disabled={voteLoading}
                className="text-gray-400 hover:text-red-500 disabled:opacity-50"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
            </div>
            <div className="text-sm text-gray-500">
              Vorgeschlagen von {alternative.submitter?.username || 'Unbekannt'}
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-3">Beschreibung</h2>
            <p className="text-gray-700">{alternative.description}</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Warum ersetzen?</h2>
              <p className="text-gray-700">{alternative.reasons}</p>
            </div>
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Vorteile</h2>
              <p className="text-gray-700">{alternative.benefits}</p>
            </div>
          </div>
        </div>
      </div>

      <div className="mt-12">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">Kommentare</h2>
        
        {isAuthenticated ? (
          <form onSubmit={handleCommentSubmit} className="mb-8">
            <TextArea
              label="Neuer Kommentar"
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
              rows={4}
              placeholder="Teilen Sie Ihre Gedanken zu dieser Alternative..."
              className="mb-3"
            />
            <Button
              type="submit"
              disabled={commentLoading || !newComment.trim()}
            >
              {commentLoading ? 'Wird gesendet...' : 'Kommentar senden'}
            </Button>
          </form>
        ) : (
          <div className="bg-gray-50 p-4 rounded-lg mb-8">
            <p className="text-gray-700">
              <Link to="/login" className="text-primary-600 hover:text-primary-800">Melden Sie sich an</Link>, um Kommentare zu hinterlassen.
            </p>
          </div>
        )}

        {comments.length === 0 ? (
          <div className="text-center py-8">
            <p className="text-gray-500">Noch keine Kommentare. Seien Sie der Erste, der einen Kommentar hinterlässt!</p>
          </div>
        ) : (
          <div className="space-y-6">
            {comments.map((comment) => (
              <div key={comment.id} className="bg-white rounded-lg shadow p-4">
                <div className="flex justify-between items-start mb-2">
                  <div className="font-medium text-gray-900">{comment.User?.username || 'Unbekannt'}</div>
                  <div className="text-xs text-gray-500">
                    {new Date(comment.createdAt).toLocaleDateString()}
                  </div>
                </div>
                <p className="text-gray-700">{comment.content}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default AlternativeDetail;
EOL

    log_info "Detailseite für Alternativen wurde erstellt."
}

# 3. Erstelle die Seite zum Vorschlagen neuer Alternativen
create_new_alternative_page() {
    log_info "Erstelle Seite für neue Alternativen..."
    
    cat > frontend/src/pages/NewAlternative.jsx << EOL
import React, { useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { Formik, Form } from 'formik';
import * as Yup from 'yup';
import Input from '../components/Input';
import TextArea from '../components/TextArea';
import Button from '../components/Button';
import { AuthContext } from '../contexts/AuthContext';
import { createAlternative, checkIfAlternativeExists } from '../services/alternativeService';

const alternativeSchema = Yup.object().shape({
  title: Yup.string()
    .min(3, 'Titel muss mindestens 3 Zeichen lang sein')
    .max(100, 'Titel darf maximal 100 Zeichen lang sein')
    .required('Titel ist erforderlich'),
  replaces: Yup.string()
    .min(3, 'Zu ersetzendes Produkt muss mindestens 3 Zeichen lang sein')
    .max(100, 'Zu ersetzendes Produkt darf maximal 100 Zeichen lang sein')
    .required('Zu ersetzendes Produkt ist erforderlich'),
  description: Yup.string()
    .min(10, 'Beschreibung muss mindestens 10 Zeichen lang sein')
    .required('Beschreibung ist erforderlich'),
  reasons: Yup.string()
    .min(10, 'Gründe müssen mindestens 10 Zeichen lang sein')
    .required('Gründe sind erforderlich'),
  benefits: Yup.string()
    .min(10, 'Vorteile müssen mindestens 10 Zeichen lang sein')
    .required('Vorteile sind erforderlich'),
  website: Yup.string()
    .url('Gültige URL erforderlich'),
  category: Yup.string()
    .required('Kategorie ist erforderlich')
});

const NewAlternative = () => {
  const { isAuthenticated } = useContext(AuthContext);
  const navigate = useNavigate();
  const [error, setError] = useState(null);
  const [similarExists, setSimilarExists] = useState(null);

  // Redirect to login if not authenticated
  React.useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login', { state: { from: '/alternatives/new' } });
    }
  }, [isAuthenticated, navigate]);

  const checkSimilarAlternatives = async (title, replaces, category) => {
    try {
      const { exists, alternative } = await checkIfAlternativeExists({ 
        name: title, 
        replaces, 
        category 
      });
      
      if (exists) {
        setSimilarExists({
          message: \`Eine ähnliche Alternative "\${alternative.title}" existiert bereits.\`,
          id: alternative.id
        });
        return true;
      }
      setSimilarExists(null);
      return false;
    } catch (err) {
      console.error('Fehler beim Überprüfen ähnlicher Alternativen:', err);
      return false;
    }
  };

  const handleSubmit = async (values, { setSubmitting }) => {
    try {
      // Erst prüfen, ob ähnliche Alternativen existieren
      const exists = await checkSimilarAlternatives(values.title, values.replaces, values.category);
      if (exists) {
        setSubmitting(false);
        return;
      }

      // Wenn nicht, Alternative erstellen
      const alternative = await createAlternative(values);
      navigate(\`/alternatives/\${alternative.id}\`);
    } catch (err) {
      setError(err.response?.data?.message || 'Fehler beim Erstellen der Alternative.');
      setSubmitting(false);
    }
  };

  if (!isAuthenticated) {
    return null; // Verhindert Flackern während der Weiterleitung
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Neue Alternative vorschlagen</h1>
      
      {error && (
        <div className="bg-red-50 p-4 rounded-lg mb-6 text-red-800">
          {error}
        </div>
      )}

      {similarExists && (
        <div className="bg-yellow-50 p-4 rounded-lg mb-6">
          <p className="text-yellow-800 mb-2">{similarExists.message}</p>
          <Button
            variant="secondary"
            onClick={() => navigate(\`/alternatives/\${similarExists.id}\`)}
          >
            Zur bestehenden Alternative
          </Button>
        </div>
      )}
      
      <div className="bg-white rounded-lg shadow-lg p-6 md:p-8">
        <Formik
          initialValues={{
            title: '',
            replaces: '',
            description: '',
            reasons: '',
            benefits: '',
            website: '',
            category: ''
          }}
          validationSchema={alternativeSchema}
          onSubmit={handleSubmit}
        >
          {({ values, errors, touched, handleChange, handleBlur, isSubmitting, setFieldValue }) => (
            <Form>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <Input
                  label="Name der Alternative *"
                  name="title"
                  placeholder="z.B. DuckDuckGo"
                  value={values.title}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  error={touched.title && errors.title}
                />
                
                <Input
                  label="Ersetzt *"
                  name="replaces"
                  placeholder="z.B. Google Search"
                  value={values.replaces}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  error={touched.replaces && errors.replaces}
                />
              </div>
              
              <div className="mb-6">
                <TextArea
                  label="Beschreibung *"
                  name="description"
                  placeholder="Beschreiben Sie die Alternative. Was ist es und was macht es?"
                  rows={4}
                  value={values.description}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  error={touched.description && errors.description}
                />
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <TextArea
                  label="Warum ersetzen? *"
                  name="reasons"
                  placeholder="Warum sollte man das Originalprodukt ersetzen? Welche Probleme gibt es damit?"
                  rows={4}
                  value={values.reasons}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  error={touched.reasons && errors.reasons}
                />
                
                <TextArea
                  label="Vorteile *"
                  name="benefits"
                  placeholder="Welche Vorteile bietet diese Alternative? Warum ist sie besser?"
                  rows={4}
                  value={values.benefits}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  error={touched.benefits && errors.benefits}
                />
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                <Input
                  label="Website"
                  name="website"
                  placeholder="https://example.com"
                  value={values.website}
                  onChange={handleChange}
                  onBlur={handleBlur}
                  error={touched.website && errors.website}
                />
                
                <div>
                  <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-1">
                    Kategorie *
                  </label>
                  <select
                    id="category"
                    name="category"
                    value={values.category}
                    onChange={handleChange}
                    onBlur={handleBlur}
                    className={\`input-field \${touched.category && errors.category ? 'border-red-500 focus:ring-red-500' : ''}\`}
                  >
                    <option value="">Kategorie auswählen</option>
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
                  {touched.category && errors.category && (
                    <p className="error-message">{errors.category}</p>
                  )}
                </div>
              </div>
              
              <div className="flex justify-end space-x-4">
                <Button
                  type="button"
                  variant="secondary"
                  onClick={() => navigate('/alternatives')}
                >
                  Abbrechen
                </Button>
                <Button
                  type="submit"
                  disabled={isSubmitting || similarExists !== null}
                >
                  {isSubmitting ? 'Wird gespeichert...' : 'Alternative vorschlagen'}
                </Button>
              </div>
            </Form>
          )}
        </Formik>
      </div>
    </div>
  );
};

export default NewAlternative;
EOL

    log_info "Seite für neue Alternativen wurde erstellt."
}

# 4. Erstelle Admin-Dashboard
create_admin_dashboard() {
    log_info "Erstelle Admin-Dashboard..."
    
    cat > frontend/src/pages/AdminDashboard.jsx << EOL
import React, { useState, useEffect, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';
import Button from '../components/Button';
import Loading from '../components/Loading';
import { getDashboardStats, approveAlternative } from '../services/adminService';

const AdminDashboard = () => {
  const { user, isAuthenticated } = useContext(AuthContext);
  const navigate = useNavigate();
  
  const [stats, setStats] = useState(null);
  const [latestAlternatives, setLatestAlternatives] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Überprüfen, ob der Benutzer angemeldet und Admin ist
    if (!isAuthenticated) {
      navigate('/login', { state: { from: '/admin' } });
      return;
    }
    
    if (isAuthenticated && !user?.isAdmin) {
      navigate('/');
      return;
    }
    
    const fetchData = async () => {
      try {
        setLoading(true);
        const data = await getDashboardStats();
        setStats(data.stats);
        setLatestAlternatives(data.latestAlternatives);
        setLoading(false);
      } catch (err) {
        setError('Fehler beim Laden der Dashboard-Daten.');
        setLoading(false);
      }
    };
    
    fetchData();
  }, [isAuthenticated, user, navigate]);
  const handleApprove = async (id, approved) => {
   try {
     await approveAlternative(id, approved);
     
     // Aktualisiere die Liste nach Genehmigung/Ablehnung
     setLatestAlternatives(
       latestAlternatives.map(alt => 
         alt.id === id ? { ...alt, approved } : alt
       )
     );
   } catch (err) {
     setError('Fehler beim Aktualisieren des Genehmigungsstatus.');
   }
 };

 if (loading) return <div className="max-w-7xl mx-auto px-4 py-8"><Loading /></div>;
 if (error) return <div className="max-w-7xl mx-auto px-4 py-8 bg-red-50 p-4 rounded text-red-800">{error}</div>;
 if (!stats) return <div className="max-w-7xl mx-auto px-4 py-8">Keine Daten verfügbar.</div>;

 return (
   <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
     <h1 className="text-3xl font-bold text-gray-900 mb-8">Admin-Dashboard</h1>
     
     <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Alternativen</h2>
         <p className="text-3xl font-bold text-primary-600">{stats.totalAlternatives}</p>
       </div>
       
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Ausstehend</h2>
         <p className="text-3xl font-bold text-yellow-500">{stats.pendingAlternatives}</p>
       </div>
       
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Benutzer</h2>
         <p className="text-3xl font-bold text-primary-600">{stats.totalUsers}</p>
       </div>
       
       <div className="bg-white rounded-lg shadow p-6">
         <h2 className="text-lg font-medium text-gray-900 mb-2">Kommentare</h2>
         <p className="text-3xl font-bold text-primary-600">{stats.totalComments}</p>
       </div>
     </div>
     
     <div className="bg-white rounded-lg shadow mb-8">
       <div className="px-6 py-4 border-b border-gray-200">
         <h2 className="text-lg font-medium text-gray-900">Neueste Alternativen</h2>
       </div>
       
       <div className="divide-y divide-gray-200">
         {latestAlternatives.length === 0 ? (
           <div className="px-6 py-4 text-gray-500">
             Keine Alternativen vorhanden.
           </div>
         ) : (
           latestAlternatives.map((alternative) => (
             <div key={alternative.id} className="px-6 py-4 flex items-center justify-between">
               <div>
                 <Link 
                   to={`/alternatives/${alternative.id}`} 
                   className="text-lg font-medium text-primary-600 hover:text-primary-800"
                 >
                   {alternative.title}
                 </Link>
                 <p className="text-sm text-gray-500">
                   Ersetzt: {alternative.replaces} | Kategorie: {alternative.category}
                 </p>
               </div>
               
               <div className="flex space-x-2">
                 {alternative.approved ? (
                   <Button 
                     variant="danger" 
                     onClick={() => handleApprove(alternative.id, false)}
                   >
                     Ablehnen
                   </Button>
                 ) : (
                   <Button 
                     onClick={() => handleApprove(alternative.id, true)}
                   >
                     Genehmigen
                   </Button>
                 )}
               </div>
             </div>
           ))
         )}
       </div>
     </div>
     
     <div className="flex space-x-4">
       <Link to="/admin/alternatives" className="btn-secondary">
         Alle Alternativen verwalten
       </Link>
       <Link to="/admin/users" className="btn-secondary">
         Benutzer verwalten
       </Link>
     </div>
   </div>
 );
};

export default AdminDashboard;
EOL

   log_info "Admin-Dashboard wurde erstellt."
}

# 5. Erstelle Admin-Alternatives-Seite
create_admin_alternatives() {
   log_info "Erstelle Admin-Alternatives-Seite..."
   
   cat > frontend/src/pages/AdminAlternatives.jsx << EOL
import React, { useState, useEffect, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';
import Button from '../components/Button';
import Loading from '../components/Loading';
import { getAlternatives } from '../services/alternativeService';
import { approveAlternative, deleteAlternative } from '../services/adminService';

const AdminAlternatives = () => {
 const { user, isAuthenticated } = useContext(AuthContext);
 const navigate = useNavigate();
 
 const [alternatives, setAlternatives] = useState([]);
 const [loading, setLoading] = useState(true);
 const [error, setError] = useState(null);
 const [page, setPage] = useState(1);
 const [totalPages, setTotalPages] = useState(1);
 const [filter, setFilter] = useState('');
 const [showApproved, setShowApproved] = useState('all'); // 'all', 'approved', 'pending'

 useEffect(() => {
   // Überprüfen, ob der Benutzer angemeldet und Admin ist
   if (!isAuthenticated) {
     navigate('/login', { state: { from: '/admin/alternatives' } });
     return;
   }
   
   if (isAuthenticated && !user?.isAdmin) {
     navigate('/');
     return;
   }
   
   const fetchAlternatives = async () => {
     try {
       setLoading(true);
       const params = { 
         page, 
         search: filter,
       };
       
       if (showApproved !== 'all') {
         params.approved = showApproved === 'approved';
       }
       
       const response = await getAlternatives(params);
       setAlternatives(response.alternatives);
       setTotalPages(response.pages);
       setLoading(false);
     } catch (err) {
       setError('Fehler beim Laden der Alternativen.');
       setLoading(false);
     }
   };
   
   fetchAlternatives();
 }, [isAuthenticated, user, navigate, page, filter, showApproved]);

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

 const handleApprove = async (id, approved) => {
   try {
     await approveAlternative(id, approved);
     
     // Aktualisiere die Liste nach Genehmigung/Ablehnung
     setAlternatives(
       alternatives.map(alt => 
         alt.id === id ? { ...alt, approved } : alt
       )
     );
   } catch (err) {
     setError('Fehler beim Aktualisieren des Genehmigungsstatus.');
   }
 };

 const handleDelete = async (id) => {
   if (!window.confirm('Möchten Sie diese Alternative wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.')) {
     return;
   }
   
   try {
     await deleteAlternative(id);
     
     // Entferne die gelöschte Alternative aus der Liste
     setAlternatives(alternatives.filter(alt => alt.id !== id));
   } catch (err) {
     setError('Fehler beim Löschen der Alternative.');
   }
 };

 if (loading && page === 1) return <div className="max-w-7xl mx-auto px-4 py-8"><Loading /></div>;
 
 return (
   <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
     <div className="flex justify-between items-center mb-8">
       <h1 className="text-3xl font-bold text-gray-900">Alternativen verwalten</h1>
       <Link to="/admin" className="btn-secondary">
         Zurück zum Dashboard
       </Link>
     </div>
     
     <div className="bg-white rounded-lg shadow p-6 mb-8">
       <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
         <div>
           <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-1">
             Suche
           </label>
           <input
             type="text"
             id="search"
             value={filter}
             onChange={(e) => {
               setFilter(e.target.value);
               setPage(1);
             }}
             placeholder="Nach Titel oder ersetztem Produkt suchen..."
             className="input-field"
           />
         </div>
         
         <div>
           <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-1">
             Status
           </label>
           <select
             id="status"
             value={showApproved}
             onChange={(e) => {
               setShowApproved(e.target.value);
               setPage(1);
             }}
             className="input-field"
           >
             <option value="all">Alle</option>
             <option value="approved">Genehmigt</option>
             <option value="pending">Ausstehend</option>
           </select>
         </div>
       </div>
     </div>
     
     {error && (
       <div className="bg-red-50 p-4 rounded-lg mb-6 text-red-800">
         {error}
       </div>
     )}
     
     <div className="bg-white rounded-lg shadow mb-8">
       <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
         <h2 className="text-lg font-medium text-gray-900">Alternativen</h2>
         <span className="text-sm text-gray-500">
           Seite {page} von {totalPages}
         </span>
       </div>
       
       {loading ? (
         <div className="p-6">
           <Loading />
         </div>
       ) : alternatives.length === 0 ? (
         <div className="px-6 py-4 text-gray-500">
           Keine Alternativen gefunden.
         </div>
       ) : (
         <div className="overflow-x-auto">
           <table className="min-w-full divide-y divide-gray-200">
             <thead className="bg-gray-50">
               <tr>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Titel
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Ersetzt
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Kategorie
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Status
                 </th>
                 <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Upvotes
                 </th>
                 <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                   Aktionen
                 </th>
               </tr>
             </thead>
             <tbody className="bg-white divide-y divide-gray-200">
               {alternatives.map((alternative) => (
                 <tr key={alternative.id}>
                   <td className="px-6 py-4 whitespace-nowrap">
                     <Link 
                       to={`/alternatives/${alternative.id}`} 
                       className="text-primary-600 hover:text-primary-800"
                     >
                       {alternative.title}
                     </Link>
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.replaces}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.category}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.approved ? (
                       <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                         Genehmigt
                       </span>
                     ) : (
                       <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                         Ausstehend
                       </span>
                     )}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap">
                     {alternative.upvotes}
                   </td>
                   <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                     <div className="flex justify-end space-x-2">
                       {alternative.approved ? (
                         <Button 
                           variant="danger" 
                           onClick={() => handleApprove(alternative.id, false)}
                           className="text-xs py-1 px-2"
                         >
                           Ablehnen
                         </Button>
                       ) : (
                         <Button 
                           onClick={() => handleApprove(alternative.id, true)}
                           className="text-xs py-1 px-2"
                         >
                           Genehmigen
                         </Button>
                       )}
                       <Button 
                         variant="danger" 
                         onClick={() => handleDelete(alternative.id)}
                         className="text-xs py-1 px-2"
                       >
                         Löschen
                       </Button>
                     </div>
                   </td>
                 </tr>
               ))}
             </tbody>
           </table>
         </div>
       )}
       
       <div className="px-6 py-4 border-t border-gray-200 flex justify-between">
         <Button
           variant="secondary"
           onClick={handlePreviousPage}
           disabled={page === 1}
         >
           Vorherige Seite
         </Button>
         <Button
           variant="secondary"
           onClick={handleNextPage}
           disabled={page === totalPages}
         >
           Nächste Seite
         </Button>
       </div>
     </div>
   </div>
 );
};

export default AdminAlternatives;
EOL

   log_info "Admin-Alternatives-Seite wurde erstellt."
}

# 6. Erstelle Admin-Service
create_admin_service() {
   log_info "Erstelle Admin-Service..."
   
   cat > frontend/src/services/adminService.js << EOL
import apiClient from './apiService';

export const getDashboardStats = async () => {
 return await apiClient.get('/admin/dashboard');
};

export const getUsers = async (params = {}) => {
 return await apiClient.get('/admin/users', { params });
};

export const updateUserAdminStatus = async (userId, isAdmin) => {
 return await apiClient.put(`/admin/users/${userId}`, { isAdmin });
};

export const approveAlternative = async (alternativeId, approved) => {
 return await apiClient.put(`/admin/alternatives/${alternativeId}/approve`, { approved });
};

export const deleteAlternative = async (alternativeId) => {
 return await apiClient.delete(`/alternatives/${alternativeId}`);
};
EOL

   log_info "Admin-Service wurde erstellt."
}

# 7. Aktualisiere App.jsx, um die neuen Routen hinzuzufügen
update_app_jsx() {
   log_info "Aktualisiere App.jsx..."
   
   cat > frontend/src/App.jsx << EOL
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import Alternatives from './pages/Alternatives';
import AlternativeDetail from './pages/AlternativeDetail';
import NewAlternative from './pages/NewAlternative';
import AdminDashboard from './pages/AdminDashboard';
import AdminAlternatives from './pages/AdminAlternatives';

function App() {
 return (
   <AuthProvider>
     <Router>
       <div className="flex flex-col min-h-screen">
         <Navbar />
         <main className="flex-grow">
           <Routes>
             <Route path="/" element={<Home />} />
             <Route path="/login" element={<Login />} />
             <Route path="/register" element={<Register />} />
             <Route path="/alternatives" element={<Alternatives />} />
             <Route path="/alternatives/:id" element={<AlternativeDetail />} />
             <Route path="/alternatives/new" element={<NewAlternative />} />
             <Route path="/admin" element={<AdminDashboard />} />
             <Route path="/admin/alternatives" element={<AdminAlternatives />} />
           </Routes>
         </main>
         <Footer />
       </div>
     </Router>
   </AuthProvider>
 );
}

export default App;
EOL

   log_info "App.jsx wurde aktualisiert."
}

# Hauptprogramm
main() {
   log_info "Starte Ergänzung fehlender Frontend-Komponenten..."
   create_alternatives_page
   create_alternative_detail_page
   create_new_alternative_page
   create_admin_dashboard
   create_admin_alternatives
   create_admin_service
   update_app_jsx
   log_info "Fehlende Frontend-Komponenten wurden erfolgreich ergänzt!"
   log_info "Starten Sie die Docker-Container neu mit 'docker-compose -f docker-compose.dev.yml restart' um die Änderungen zu übernehmen."
}

# Führe das Hauptprogramm aus
main