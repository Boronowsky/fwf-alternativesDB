import React from 'react';

const Input = ({ 
  label, 
  name, 
  type = 'text', 
  placeholder = '', 
  value, 
  onChange, 
  onBlur,
  error, 
  className = '', 
  ...props 
}) => {
  return (
    <div className={className}>
      {label && (
        <label htmlFor={name} className="block text-sm font-medium text-gray-700 mb-1">
          {label}
        </label>
      )}
      <input
        id={name}
        name={name}
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
        className={`input-field ${error ? 'border-red-500 focus:ring-red-500' : ''}`}
        {...props}
      />
      {error && <p className="error-message">{error}</p>}
    </div>
  );
};

export default Input;
