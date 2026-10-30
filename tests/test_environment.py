import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class EnvironmentTests(unittest.TestCase):
    def test_executable_dependencies_have_restorable_versioned_records(self):
        lock = json.loads((ROOT / 'renv.lock').read_text())
        required = (ROOT / 'scripts/required-packages.txt').read_text().splitlines()
        self.assertTrue(set(required) <= set(lock['Packages']))
        for name, record in lock['Packages'].items():
            with self.subTest(package=name):
                self.assertEqual(record['Package'], name)
                self.assertRegex(record['Version'], r'^\d+(?:[.-]\d+)*$')
                self.assertEqual(record['Source'], 'Repository')
                self.assertEqual(record['Repository'], 'CRAN')
        self.assertEqual(lock['R']['Version'], '4.6.1')

if __name__ == '__main__':
    unittest.main()
