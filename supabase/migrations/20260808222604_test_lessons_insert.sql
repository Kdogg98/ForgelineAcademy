DO $$
DECLARE c_id uuid; m_id uuid;
BEGIN
  SELECT id INTO c_id FROM courses WHERE stage='engineering' AND title='System Architecture & Network Design';
  IF NOT FOUND THEN RETURN; END IF;

  INSERT INTO modules (course_id, title, sort_order) VALUES (c_id, 'TEST MODULE TO DELETE', 99) RETURNING id INTO m_id;
  INSERT INTO lessons (module_id, title, content, estimated_minutes, sort_order, quiz) VALUES
  (m_id, 'TEST LESSON TO DELETE', 'test content', 5, 1, '[]'::jsonb);
END $$;