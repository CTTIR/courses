import contextlib
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('graph', ROOT / 'scripts/build_graph.py')
graph = importlib.util.module_from_spec(spec)
spec.loader.exec_module(graph)

class GraphTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.old = graph.ROOT, graph.LABS_YAML, graph.COURSES_YAML, graph.ARTIFACTS
        graph.ROOT = self.root
        graph.LABS_YAML = self.root / 'labs.yml'
        graph.COURSES_YAML = self.root / 'courses.yml'
        graph.ARTIFACTS = self.root / 'artifacts'
        for name in ('labs', 'courses'):
            (self.root / (name + '.yml')).write_text((ROOT / '_data' / (name + '.yml')).read_text())
        for p in ROOT.glob('course*/*/lab_*'):
            if p.suffix in ('.qmd', '.R'):
                target = self.root / p.relative_to(ROOT)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text('fixture')
    def tearDown(self):
        graph.ROOT, graph.LABS_YAML, graph.COURSES_YAML, graph.ARTIFACTS = self.old
        self.temp.cleanup()
    def run_graph(self):
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return graph.main()
    def test_complete_curriculum(self):
        self.assertEqual(self.run_graph(), 0)
    def test_missing_script_rejected(self):
        next(self.root.glob('course*/code/*.R')).unlink()
        self.assertEqual(self.run_graph(), 1)
    def test_duplicate_lab_rejected(self):
        text = graph.LABS_YAML.read_text()
        start = text.index('  - id:')
        end = text.index('  - id:', start + 1)
        graph.LABS_YAML.write_text(text + '\n' + text[start:end])
        self.assertEqual(self.run_graph(), 1)
    def test_traversal_and_mismatched_identifiers_rejected(self):
        graph.LABS_YAML.write_text(graph.LABS_YAML.read_text().replace('course1/lab_week1_session1', 'course1/../../escape', 1))
        self.assertEqual(self.run_graph(), 1)
    def test_duplicate_course_rejected(self):
        graph.COURSES_YAML.write_text(graph.COURSES_YAML.read_text().replace('slug: course2','slug: course1',1))
        self.assertEqual(self.run_graph(), 1)

if __name__ == '__main__':
    unittest.main()
