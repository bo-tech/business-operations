# Configuration file for the Sphinx documentation builder.

from pathlib import Path

# -- Project information -----------------------------------------------------

project = 'Business Operations'
copyright = '2023-2026, Johannes Bornhold <johannes@bornhold.name>'
author = 'Johannes Bornhold'

version = (Path(__file__).resolve().parent.parent / 'VERSION').read_text().strip()
release = version


# -- General configuration ---------------------------------------------------

extensions = [
    'myst_parser',
    'sphinx.ext.extlinks',
    'sphinx.ext.ifconfig',
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
]

templates_path = ['_templates']

exclude_patterns = [
    '.DS_Store',
    'Thumbs.db',
    '_build',
    'decisions/README.md',
    'decisions/adr-template.md',
    'README.md',
]


# -- Options for HTML output -------------------------------------------------

html_theme = "sphinx_book_theme"

html_static_path = []


# -- Options for PDF output -------------------------------------------------

latex_documents = [
    ('index', 'business-operations.tex', project, author, 'manual'),
]


intersphinx_mapping = {}
