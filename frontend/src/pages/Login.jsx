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
