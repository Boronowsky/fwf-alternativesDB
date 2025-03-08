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
