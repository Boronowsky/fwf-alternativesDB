import React from 'react';

const TextArea = ({ 
  label, 
  name, 
  placeholder = '', 
  value, 
  onChange, 
  onBlur,
  error, 
  className = '', 
  rows = 4,
  ...props 
}) => {
  return (
    <div className={className}>
      {label && (
        <label htmlFor={name} className="block text-sm font-medium text-gray-700 mb-1">
          {label}
        </label>
      )}
      <textarea
        id={name}
        name={name}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
        rows={rows}
        className={`input-field ${error ? 'border-red-500 focus:ring-red-500' : ''}`}
        {...props}
      />
      {error && <p className="error-message">{error}</p>}
    </div>
  );
};

export default TextArea;
