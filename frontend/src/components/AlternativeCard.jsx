import React from 'react';
import { Link } from 'react-router-dom';

const AlternativeCard = ({ alternative }) => {
  return (
    <div className="card hover:shadow-lg transition-shadow">
      <h3 className="text-lg font-semibold text-gray-900 mb-2">{alternative.title}</h3>
      <div className="flex items-center mb-4">
        <div className="flex-1">
          <span className="text-sm text-gray-500">
            Ersetzt: <span className="font-medium text-gray-700">{alternative.replaces}</span>
          </span>
        </div>
        <div className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">
          {alternative.category}
        </div>
      </div>
      <p className="text-gray-600 mb-4 line-clamp-3">{alternative.description}</p>
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-1">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-primary-500" viewBox="0 0 20 20" fill="currentColor">
            <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
          </svg>
          <span className="text-sm text-gray-600">{alternative.upvotes}</span>
        </div>
        <Link to={"/alternatives/" + alternative.id} className="text-primary-600 hover:text-primary-700 text-sm font-medium">
          Mehr erfahren &rarr;
        </Link>
      </div>
    </div>
  );
};

export default AlternativeCard;
