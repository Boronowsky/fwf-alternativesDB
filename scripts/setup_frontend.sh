echo "SKRIPT WIRD AUSGEFÜHRT"
#!/bin/bash
# setup_frontend.sh - Erstellt die Frontend-Anwendung für FreeWorldFirst Collector

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

# Erstellt package.json für das Frontend
create_package_json() {
    log_info "Erstelle package.json für das Frontend..."
    
    cat > frontend/package.json << EOL
{
  "name": "freeworldfirst-collector-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@headlessui/react": "^1.7.7",
    "@heroicons/react": "^2.0.13",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.2.1",
    "formik": "^2.2.9",
    "jwt-decode": "^3.1.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.6.1",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4",
    "yup": "^0.32.11"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "devDependencies": {
    "autoprefixer": "^10.4.13",
    "postcss": "^8.4.20",
    "tailwindcss": "^3.2.4"
  }
}
EOL

    log_info "package.json für das Frontend wurde erstellt."
}

# Erstellt Tailwind-Konfiguration
create_tailwind_config() {
    log_info "Erstelle Tailwind-Konfiguration..."
    
    cat > frontend/tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f2f9ff',
          100: '#e6f3ff',
          200: '#bfdfff',
          300: '#99ccff',
          400: '#4da6ff',
          500: '#0080ff',
          600: '#0073e6',
          700: '#0060bf',
          800: '#004d99',
          900: '#003f7d',
        },
      },
    },
  },
  plugins: [],
}
EOL

    cat > frontend/postcss.config.js << EOL
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOL

    log_info "Tailwind-Konfiguration wurde erstellt."
}

# Erstellt die Grundstruktur der React-App
create_react_app_structure() {
    log_info "Erstelle React-App-Struktur..."
    
    mkdir -p frontend/src/components
    mkdir -p frontend/src/pages
    mkdir -p frontend/src/contexts
    mkdir -p frontend/src/services
    mkdir -p frontend/src/utils
    mkdir -p frontend/public
    
    # Erstelle index.html
    cat > frontend/public/index.html << EOL
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#0080ff" />
    <meta name="description" content="FreeWorldFirst Collector - Ethische Alternativen zu BigTech-Produkten finden" />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>FreeWorldFirst Collector</title>
</head>
<body>
    <noscript>Sie müssen JavaScript aktivieren, um diese App nutzen zu können.</noscript>
    <div id="root"></div>
</body>
</html>
EOL

    # Erstelle manifest.json
    cat > frontend/public/manifest.json << EOL
{
  "short_name": "FWF Collector",
  "name": "FreeWorldFirst Collector",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#0080ff",
  "background_color": "#ffffff"
}
EOL

    log_info "React-App-Struktur wurde erstellt."
}

# Erstellt CSS-Datei mit Tailwind-Direktiven
create_css_file() {
    log_info "Erstelle CSS-Datei mit Tailwind-Direktiven..."
    
    cat > frontend/src/index.css << EOL
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-primary-500 text-white rounded hover:bg-primary-600 transition-colors;
  }
  
  .btn-secondary {
    @apply px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300 transition-colors;
  }
  
  .input-field {
    @apply w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500;
  }
  
  .card {
    @apply bg-white p-6 rounded-lg shadow-md;
  }
  
  .error-message {
    @apply text-red-500 text-sm mt-1;
  }
}

body {
  @apply bg-gray-50 text-gray-900;
}
EOL

    log_info "CSS-Datei wurde erstellt."
}

# Erstellt Komponenten
create_components() {
    log_info "Erstelle Komponenten..."
    
    # Navbar-Komponente
    cat > frontend/src/components/Navbar.jsx << EOL
import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';

const Navbar = () => {
  const { user, logout } = useContext(AuthContext);

  return (
    <nav className="bg-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="flex-shrink-0 flex items-center">
              <span className="text-xl font-bold text-primary-600">FreeWorldFirst</span>
              <span className="ml-1 text-gray-600">Collector</span>
            </Link>
            <div className="ml-10 flex space-x-4">
              <Link to="/" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                Startseite
              </Link>
              <Link to="/alternatives" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                Alternativen
              </Link>
              <Link to="/about" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                Über uns
              </Link>
            </div>
          </div>
          <div className="flex items-center">
            {user ? (
              <div className="flex items-center space-x-4">
                {user.isAdmin && (
                  <Link to="/admin" className="px-3 py-2 rounded-md text-sm font-medium text-primary-600 hover:bg-primary-50">
                    Admin
                  </Link>
                )}
                <span className="text-sm text-gray-700">Hallo, {user.username}</span>
                <button 
                  onClick={logout}
                  className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-red-600 hover:bg-gray-50"
                >
                  Abmelden
                </button>
              </div>
            ) : (
              <div className="flex items-center space-x-4">
                <Link to="/login" className="px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50">
                  Anmelden
                </Link>
                <Link to="/register" className="px-3 py-2 rounded-md text-sm font-medium bg-primary-500 text-white hover:bg-primary-600 px-4 py-2 rounded">
                  Registrieren
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
EOL

    # Footer-Komponente
    cat > frontend/src/components/Footer.jsx << EOL
import React from 'react';
import { Link } from 'react-router-dom';

const Footer = () => {
  return (
    <footer className="bg-white mt-12 py-8 border-t">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">FreeWorldFirst Collector</h3>
            <p className="text-gray-600">
              Eine Plattform für ethische Alternativen zu BigTech-Produkten und -Diensten.
            </p>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Links</h3>
            <ul className="space-y-2">
              <li>
                <Link to="/" className="text-gray-600 hover:text-primary-600">
                  Startseite
                </Link>
              </li>
              <li>
                <Link to="/alternatives" className="text-gray-600 hover:text-primary-600">
                  Alternativen
                </Link>
              </li>
              <li>
                <Link to="/about" className="text-gray-600 hover:text-primary-600">
                  Über uns
                </Link>
              </li>
            </ul>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Rechtliches</h3>
            <ul className="space-y-2">
              <li>
                <Link to="/privacy" className="text-gray-600 hover:text-primary-600">
                  Datenschutz
                </Link>
              </li>
              <li>
                <Link to="/terms" className="text-gray-600 hover:text-primary-600">
                  Nutzungsbedingungen
                </Link>
              </li>
              <li>
                <Link to="/imprint" className="text-gray-600 hover:text-primary-600">
                  Impressum
                </Link>
              </li>
            </ul>
          </div>
        </div>
        <div className="mt-8 pt-8 border-t border-gray-200">
<p className="text-center text-gray-600">
            &copy; {new Date().getFullYear()} FreeWorldFirst Collector. Alle Rechte vorbehalten.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
EOL

    # AlternativeCard-Komponente
    cat > frontend/src/components/AlternativeCard.jsx << EOL
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
        <Link to={`/alternatives/\${alternative.id}`} className="text-primary-600 hover:text-primary-700 text-sm font-medium">
          Mehr erfahren &rarr;
        </Link>
      </div>
    </div>
  );
};

export default AlternativeCard;
EOL

    # Button-Komponente
    cat > frontend/src/components/Button.jsx << EOL
import React from 'react';

const Button = ({ 
  children, 
  type = 'button', 
  variant = 'primary', 
  className = '', 
  disabled = false, 
  onClick,
  ...props 
}) => {
  const baseClasses = 'inline-flex items-center justify-center px-4 py-2 border text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed';
  
  const variantClasses = {
    primary: 'border-transparent text-white bg-primary-600 hover:bg-primary-700 focus:ring-primary-500',
    secondary: 'border-gray-300 text-gray-700 bg-white hover:bg-gray-50 focus:ring-primary-500',
    danger: 'border-transparent text-white bg-red-600 hover:bg-red-700 focus:ring-red-500',
  };
  
  return (
    <button
      type={type}
      className={\`\${baseClasses} \${variantClasses[variant]} \${className}\`}
      disabled={disabled}
      onClick={onClick}
      {...props}
    >
      {children}
    </button>
  );
};

export default Button;
EOL

    # Input-Komponente
    cat > frontend/src/components/Input.jsx << EOL
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
        className={\`input-field \${error ? 'border-red-500 focus:ring-red-500' : ''}\`}
        {...props}
      />
      {error && <p className="error-message">{error}</p>}
    </div>
  );
};

export default Input;
EOL

    # TextArea-Komponente
    cat > frontend/src/components/TextArea.jsx << EOL
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
        className={\`input-field \${error ? 'border-red-500 focus:ring-red-500' : ''}\`}
        {...props}
      />
      {error && <p className="error-message">{error}</p>}
    </div>
  );
};

export default TextArea;
EOL

    # Loading-Komponente
    cat > frontend/src/components/Loading.jsx << EOL
import React from 'react';

const Loading = ({ size = 'medium' }) => {
  const sizeClasses = {
    small: 'w-5 h-5',
    medium: 'w-8 h-8',
    large: 'w-12 h-12',
  };

  return (
    <div className="flex items-center justify-center">
      <svg 
        className={\`animate-spin text-primary-500 \${sizeClasses[size]}\`} 
        xmlns="http://www.w3.org/2000/svg" 
        fill="none" 
        viewBox="0 0 24 24"
      >
        <circle 
          className="opacity-25" 
          cx="12" 
          cy="12" 
          r="10" 
          stroke="currentColor" 
          strokeWidth="4"
        ></circle>
        <path 
          className="opacity-75" 
          fill="currentColor" 
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        ></path>
      </svg>
    </div>
  );
};

export default Loading;
EOL

    log_info "Komponenten wurden erstellt."
}

# Erstellt Seiten
create_pages() {
    log_info "Erstelle Seiten..."
    
    # Home-Seite
    cat > frontend/src/pages/Home.jsx << EOL
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
EOL

    # Login-Seite
    cat > frontend/src/pages/Login.jsx << EOL
import React, { useContext, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Formik, Form } from 'formik';
import * as Yup from 'yup';
import Input from '../components/Input';
import Button from '../components/Button';
import { AuthContext } from '../contexts/AuthContext';

const loginSchema = Yup.object().shape({
  email: Yup.string()
    .email('Ungültige E-Mail-Adresse')
    .required('E-Mail ist erforderlich'),
  password: Yup.string()
    .required('Passwort ist erforderlich'),
});

const Login = () => {
  const { login } = useContext(AuthContext);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleSubmit = async (values, { setSubmitting }) => {
    try {
      await login(values.email, values.password);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Anmeldung fehlgeschlagen.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-md mx-auto px-4 py-12">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">Anmelden</h2>
        
        {error && (
          <div className="bg-red-50 text-red-700 p-3 rounded mb-4">
            {error}
          </div>
        )}
        
        <Formik
          initialValues={{ email: '', password: '' }}
          validationSchema={loginSchema}
          onSubmit={handleSubmit}
        >
          {({ values, errors, touched, handleChange, handleBlur, isSubmitting }) => (
            <Form>
              <Input
                label="E-Mail"
                name="email"
                type="email"
                placeholder="ihre@email.de"
                value={values.email}
                onChange={handleChange}
                onBlur={handleBlur}
                error={touched.email && errors.email}
                className="mb-4"
              />
              
              <Input
                label="Passwort"
                name="password"
                type="password"
                placeholder="Ihr Passwort"
                value={values.password}
                onChange={handleChange}
                onBlur={handleBlur}
                error={touched.password && errors.password}
                className="mb-6"
              />
              
              <Button
                type="submit"
                variant="primary"
                className="w-full"
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Wird angemeldet...' : 'Anmelden'}
              </Button>
            </Form>
          )}
        </Formik>
        
        <div className="mt-4 text-center text-sm text-gray-600">
          Noch kein Konto? <Link to="/register" className="text-primary-600 hover:text-primary-500">Registrieren</Link>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOL

    # Register-Seite
    cat > frontend/src/pages/Register.jsx << EOL
import React, { useContext, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Formik, Form } from 'formik';
import * as Yup from 'yup';
import Input from '../components/Input';
import Button from '../components/Button';
import { AuthContext } from '../contexts/AuthContext';

const registerSchema = Yup.object().shape({
  username: Yup.string()
    .min(3, 'Benutzername muss mindestens 3 Zeichen lang sein')
    .max(20, 'Benutzername darf maximal 20 Zeichen lang sein')
    .required('Benutzername ist erforderlich'),
  email: Yup.string()
    .email('Ungültige E-Mail-Adresse')
    .required('E-Mail ist erforderlich'),
  password: Yup.string()
    .min(8, 'Passwort muss mindestens 8 Zeichen lang sein')
    .matches(/[a-zA-Z]/, 'Passwort muss mindestens einen Buchstaben enthalten')
    .matches(/[0-9]/, 'Passwort muss mindestens eine Zahl enthalten')
    .required('Passwort ist erforderlich'),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('password'), null], 'Passwörter müssen übereinstimmen')
    .required('Passwort-Bestätigung ist erforderlich'),
});

const Register = () => {
  const { register } = useContext(AuthContext);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleSubmit = async (values, { setSubmitting }) => {
    try {
      await register(values.username, values.email, values.password);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || 'Registrierung fehlgeschlagen.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-md mx-auto px-4 py-12">
      <div className="card">
        <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">Registrieren</h2>
        
        {error && (
          <div className="bg-red-50 text-red-700 p-3 rounded mb-4">
            {error}
          </div>
        )}
        
        <Formik
          initialValues={{ username: '', email: '', password: '', confirmPassword: '' }}
          validationSchema={registerSchema}
          onSubmit={handleSubmit}
        >
          {({ values, errors, touched, handleChange, handleBlur, isSubmitting }) => (
            <Form>
              <Input
                label="Benutzername"
                name="username"
                placeholder="Ihr Benutzername"
                value={values.username}
                onChange={handleChange}
                onBlur={handleBlur}
                error={touched.username && errors.username}
                className="mb-4"
              />
              
              <Input
                label="E-Mail"
                name="email"
                type="email"
                placeholder="ihre@email.de"
                value={values.email}
                onChange={handleChange}
                onBlur={handleBlur}
                error={touched.email && errors.email}
                className="mb-4"
              />
              
              <Input
                label="Passwort"
                name="password"
                type="password"
                placeholder="Mindestens 8 Zeichen"
                value={values.password}
                onChange={handleChange}
                onBlur={handleBlur}
                error={touched.password && errors.password}
                className="mb-4"
              />
              
              <Input
                label="Passwort bestätigen"
                name="confirmPassword"
                type="password"
                placeholder="Passwort wiederholen"
                value={values.confirmPassword}
                onChange={handleChange}
                onBlur={handleBlur}
                error={touched.confirmPassword && errors.confirmPassword}
                className="mb-6"
              />
              
              <Button
                type="submit"
                variant="primary"
                className="w-full"
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Registrierung läuft...' : 'Registrieren'}
              </Button>
            </Form>
          )}
        </Formik>
        
        <div className="mt-4 text-center text-sm text-gray-600">
          Bereits registriert? <Link to="/login" className="text-primary-600 hover:text-primary-500">Anmelden</Link>
        </div>
      </div>
    </div>
  );
};

export default Register;
EOL

    log_info "Seiten wurden erstellt."
}

# Erstellt Contexts
create_contexts() {
    log_info "Erstelle Contexts..."
    
    # AuthContext
    cat > frontend/src/contexts/AuthContext.jsx << EOL
import React, { createContext, useState, useEffect } from 'react';
import jwt_decode from 'jwt-decode';
import { login as apiLogin, register as apiRegister } from '../services/authService';

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Beim Laden der App prüfen, ob ein Token im localStorage existiert
    const token = localStorage.getItem('token');
    if (token) {
      try {
        // Token dekodieren und überprüfen
        const decoded = jwt_decode(token);
        const currentTime = Date.now() / 1000;
        
        if (decoded.exp > currentTime) {
          setUser({
            id: decoded.id,
            username: decoded.username,
            email: decoded.email,
            isAdmin: decoded.isAdmin || false
          });
        } else {
          // Token ist abgelaufen
          localStorage.removeItem('token');
        }
      } catch (err) {
        localStorage.removeItem('token');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    const response = await apiLogin(email, password);
    const { token } = response;
    
    localStorage.setItem('token', token);
    const decoded = jwt_decode(token);
    
    setUser({
      id: decoded.id,
      username: decoded.username,
      email: decoded.email,
      isAdmin: decoded.isAdmin || false
    });
    
    return response;
  };

  const register = async (username, email, password) => {
    const response = await apiRegister(username, email, password);
    const { token } = response;
    
    localStorage.setItem('token', token);
    const decoded = jwt_decode(token);
    
    setUser({
      id: decoded.id,
      username: decoded.username,
      email: decoded.email,
      isAdmin: decoded.isAdmin || false
    });
    
    return response;
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  return (
    <AuthContext.Provider 
      value={{ 
        user, 
        login, 
        register, 
        logout,
        isAuthenticated: !!user,
        isLoading: loading
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
EOL

    log_info "Contexts wurden erstellt."
}

# Erstellt Services
create_services() {
    log_info "Erstelle Services..."
    
    # API-Service
    cat > frontend/src/services/apiService.js << EOL
import axios from 'axios';

const API_URL = process.env.NODE_ENV === 'development' 
  ? 'http://localhost:8100/api'
  : 'http://freeworldfirst.com:8000/api';

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request-Interceptor für das Hinzufügen des Auth-Tokens
apiClient.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['Authorization'] = \`Bearer \${token}\`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// Response-Interceptor für einheitliche Fehlerbehandlung
apiClient.interceptors.response.use(
  response => response.data,
  error => {
    // Wenn Token abgelaufen oder ungültig ist
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
EOL

    # Auth-Service
    cat > frontend/src/services/authService.js << EOL
import apiClient from './apiService';

export const login = async (email, password) => {
  return await apiClient.post('/auth/login', { email, password });
};

export const register = async (username, email, password) => {
  return await apiClient.post('/auth/register', { username, email, password });
};

export const getProfile = async () => {
  return await apiClient.get('/auth/profile');
};

export const updateProfile = async (userData) => {
  return await apiClient.put('/auth/profile', userData);
};

export const changePassword = async (oldPassword, newPassword) => {
  return await apiClient.put('/auth/password', { oldPassword, newPassword });
};
EOL

    # Alternative-Service
    cat > frontend/src/services/alternativeService.js << EOL
import apiClient from './apiService';

export const getAlternatives = async (params = {}) => {
  return await apiClient.get('/alternatives', { params });
};

export const getLatestAlternatives = async (limit = 6) => {
  return await apiClient.get('/alternatives/latest', { params: { limit } });
};

export const getAlternativeById = async (id) => {
  return await apiClient.get(\`/alternatives/\${id}\`);
};

export const createAlternative = async (alternativeData) => {
  return await apiClient.post('/alternatives', alternativeData);
};

export const updateAlternative = async (id, alternativeData) => {
  return await apiClient.put(\`/alternatives/\${id}\`, alternativeData);
};

export const deleteAlternative = async (id) => {
  return await apiClient.delete(\`/alternatives/\${id}\`);
};

export const upvoteAlternative = async (id) => {
  return await apiClient.post(\`/alternatives/\${id}/upvote\`);
};

export const downvoteAlternative = async (id) => {
  return await apiClient.post(\`/alternatives/\${id}/downvote\`);
};

export const addComment = async (id, content) => {
  return await apiClient.post(\`/alternatives/\${id}/comments\`, { content });
};

export const getComments = async (id) => {
  return await apiClient.get(\`/alternatives/\${id}/comments\`);
};

export const checkIfAlternativeExists = async (name) => {
  return await apiClient.get('/alternatives/check', { params: { name } });
};
EOL

    log_info "Services wurden erstellt."
}

# Erstellt Haupt-App-Dateien
create_main_files() {
    log_info "Erstelle Haupt-App-Dateien..."
    
    # index.js
    cat > frontend/src/index.js << EOL
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

reportWebVitals();
EOL

    # App.js
    cat > frontend/src/App.jsx << EOL
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';

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
              {/* Weitere Routen werden hier hinzugefügt */}
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

    # reportWebVitals.js
    cat > frontend/src/reportWebVitals.js << EOL
const reportWebVitals = (onPerfEntry) => {
  if (onPerfEntry && onPerfEntry instanceof Function) {
    import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
      getCLS(onPerfEntry);
      getFID(onPerfEntry);
      getFCP(onPerfEntry);
      getLCP(onPerfEntry);
      getTTFB(onPerfEntry);
    });
  }
};

export default reportWebVitals;
EOL

    log_info "Haupt-App-Dateien wurden erstellt."
}
# Hauptprogramm
main() {
    log_info "Starte Erstellung der Frontend-Anwendung..."
    create_package_json
    create_tailwind_config
    create_react_app_structure
    create_css_file
    create_components
    create_pages
    create_contexts
    create_services
    create_main_files
    log_info "Frontend-Anwendung wurde erfolgreich erstellt!"
}

# Führe das Hauptprogramm aus
main