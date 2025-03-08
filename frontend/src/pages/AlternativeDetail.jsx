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
      navigate('/login', { state: { from: `/alternatives/${id}` } });
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
      navigate('/login', { state: { from: `/alternatives/${id}` } });
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
      navigate('/login', { state: { from: `/alternatives/${id}` } });
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
