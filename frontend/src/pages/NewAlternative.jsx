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
          message: `Eine ähnliche Alternative "${alternative.title}" existiert bereits.`,
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
      navigate(`/alternatives/${alternative.id}`);
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
            onClick={() => navigate(`/alternatives/${similarExists.id}`)}
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
                    className={`input-field ${touched.category && errors.category ? 'border-red-500 focus:ring-red-500' : ''}`}
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
