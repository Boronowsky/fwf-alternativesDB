import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const AlternativeCard = ({ alternative, onBookmarkToggle }) => {
  const { user } = useAuth();
  const [isBookmarked, setIsBookmarked] = useState(false);
  const [bookmarkLoading, setBookmarkLoading] = useState(false);

  const handleBookmark = async (e) => {
    e.preventDefault();
    if (!user) return;

    setBookmarkLoading(true);
    try {
      if (onBookmarkToggle) {
        await onBookmarkToggle(alternative.id, !isBookmarked);
        setIsBookmarked(!isBookmarked);
      }
    } catch (error) {
      console.error('Bookmark error:', error);
    } finally {
      setBookmarkLoading(false);
    }
  };

  return (
    <div className="card hover:shadow-lg transition-shadow">
      <div className="flex justify-between items-start mb-2">
        <h3 className="text-lg font-semibold text-primary-dark flex-1">{alternative.title}</h3>
        {user && (
          <button
            onClick={handleBookmark}
            disabled={bookmarkLoading}
            className="ml-2 p-1 hover:bg-gray-100 rounded transition-colors"
            title={isBookmarked ? 'Bookmark entfernen' : 'Bookmarken'}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className={`h-5 w-5 ${isBookmarked ? 'text-yellow-500 fill-current' : 'text-gray-400'}`}
              fill={isBookmarked ? 'currentColor' : 'none'}
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
              />
            </svg>
          </button>
        )}
      </div>

      <div className="flex items-center mb-3">
        <div className="flex-1">
          <span className="text-sm text-gray-500">
            Ersetzt: <span className="font-medium text-primary-earth">{alternative.replaces}</span>
          </span>
        </div>
        <div className="bg-primary-light/20 text-primary-dark text-xs px-2 py-1 rounded-full">
          {alternative.category}
        </div>
      </div>

      {/* Tags */}
      {alternative.Tags && alternative.Tags.length > 0 && (
        <div className="flex flex-wrap gap-1 mb-3">
          {alternative.Tags.map((tag) => (
            <span
              key={tag.id}
              className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium"
              style={{
                backgroundColor: `${tag.color}20`,
                color: tag.color
              }}
            >
              {tag.name}
            </span>
          ))}
        </div>
      )}

      <p className="text-gray-600 mb-4 line-clamp-3">{alternative.description}</p>

      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-1">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-primary-medium" viewBox="0 0 20 20" fill="currentColor">
            <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
          </svg>
          <span className="text-sm text-gray-600">{alternative.upvotes || 0}</span>
        </div>
        <Link to={"/alternatives/" + alternative.id} className="text-primary-medium hover:text-primary-dark text-sm font-medium">
          Mehr erfahren &rarr;
        </Link>
      </div>
    </div>
  );
};

export default AlternativeCard;