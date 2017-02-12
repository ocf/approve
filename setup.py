from setuptools import find_packages
from setuptools import setup

try:
    with open('.version') as f:
        VERSION = f.readline().strip()
except IOError:
    VERSION = 'unknown'

setup(
    name='approve',
    version=VERSION,
    py_modules=['approve'],
    url='https://www.ocf.berkeley.edu/',
    author='Open Computing Facility',
    author_email='help@ocf.berkeley.edu',
    entry_points={
        'console_scripts': {
            'approve = approve:main',
        },
    },
    classifiers=[
        'Programming Language :: Python :: 3',
    ],
)
