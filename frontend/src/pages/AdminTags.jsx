import React, { useState, useEffect } from 'react';
import { getAllTags, createTag, updateTag, deleteTag } from '../services/tagService';
import Button from '../components/Button';
import Input from '../components/Input';

const AdminTags = () => {
  const [tags, setTags] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingTag, setEditingTag] = useState(null);
  const [newTag, setNewTag] = useState({ name: '', color: '#3B82F6' });

  useEffect(() => {
    fetchTags();
  }, []);

  const fetchTags = async () => {
    try {
      const data = await getAllTags();
      setTags(data);
      setLoading(false);
    } catch (err) {
      console.error('Fehler beim Laden der Tags:', err);
      setLoading(false);
    }
  };

  const handleCreateTag = async (e) => {
    e.preventDefault();
    try {
      await createTag(newTag);
      setNewTag({ name: '', color: '#3B82F6' });
      fetchTags();
    } catch (err) {
      console.error('Fehler beim Erstellen des Tags:', err);
      alert('Fehler beim Erstellen des Tags');
    }
  };

  const handleUpdateTag = async (e) => {
    e.preventDefault();
    try {
      await updateTag(editingTag.id, editingTag);
      setEditingTag(null);
      fetchTags();
    } catch (err) {
      console.error('Fehler beim Aktualisieren des Tags:', err);
      alert('Fehler beim Aktualisieren des Tags');
    }
  };

  const handleDeleteTag = async (tagId) => {
    if (!window.confirm('Tag wirklich löschen?')) return;

    try {
      await deleteTag(tagId);
      fetchTags();
    } catch (err) {
      console.error('Fehler beim Löschen des Tags:', err);
      alert('Fehler beim Löschen des Tags');
    }
  };

  if (loading) {
    return <div className="text-center py-12">Lädt...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-12">
      <h1 className="text-3xl font-bold mb-8">Tag-Verwaltung</h1>

      {/* Neuer Tag */}
      <div className="card mb-8">
        <h2 className="text-xl font-semibold mb-4">Neuer Tag</h2>
        <form onSubmit={handleCreateTag} className="flex gap-4 items-end">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Name
            </label>
            <Input
              type="text"
              value={newTag.name}
              onChange={(e) => setNewTag({ ...newTag, name: e.target.value })}
              placeholder="z.B. Open Source"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Farbe
            </label>
            <input
              type="color"
              value={newTag.color}
              onChange={(e) => setNewTag({ ...newTag, color: e.target.value })}
              className="h-10 w-20 rounded border border-gray-300"
            />
          </div>
          <Button type="submit">Erstellen</Button>
        </form>
      </div>

      {/* Tag-Liste */}
      <div className="space-y-4">
        {tags.map((tag) => (
          <div key={tag.id} className="card">
            {editingTag?.id === tag.id ? (
              <form onSubmit={handleUpdateTag} className="flex gap-4 items-end">
                <div className="flex-1">
                  <Input
                    type="text"
                    value={editingTag.name}
                    onChange={(e) =>
                      setEditingTag({ ...editingTag, name: e.target.value })
                    }
                    required
                  />
                </div>
                <div>
                  <input
                    type="color"
                    value={editingTag.color}
                    onChange={(e) =>
                      setEditingTag({ ...editingTag, color: e.target.value })
                    }
                    className="h-10 w-20 rounded border border-gray-300"
                  />
                </div>
                <Button type="submit" variant="primary">
                  Speichern
                </Button>
                <Button
                  type="button"
                  variant="secondary"
                  onClick={() => setEditingTag(null)}
                >
                  Abbrechen
                </Button>
              </form>
            ) : (
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <span
                    className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                    style={{
                      backgroundColor: `${tag.color}20`,
                      color: tag.color,
                    }}
                  >
                    {tag.name}
                  </span>
                  <span className="text-sm text-gray-500">{tag.slug}</span>
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="secondary"
                    onClick={() => setEditingTag(tag)}
                  >
                    Bearbeiten
                  </Button>
                  <Button
                    variant="secondary"
                    onClick={() => handleDeleteTag(tag.id)}
                  >
                    Löschen
                  </Button>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default AdminTags;
