Replication files for Ball et al. (2020)
========================================

Data and replication files for all analyses presented Ball et al. (2020) 'Commentary on "Gender Issues in Fundamental Physics: A Bibliometric Analysis", Alessandro Strumia'.

Import data
-------------------------------

``1-import.py`` imports the raw InSpire data (``data/InSpire.dat``), merges it with data on authors' gender (``data/AuthoID2Gender.nb``) and creates a single SQLite database file (``data/strumia.db``; see ``data/schema.sql`` for database structure). Execute it with the following command.

.. code-block:: bash

	$ python 1-import.py

Transform data
---------------------------

``2-transform.do`` is a Stata do file. It imports and merges data from various tables in ``data/strumia.db`` and generates a single Stata data file containing one observation per article (``data/strumia.dta``). Execute it in Stata with the following command.

.. code-block:: stata

	. do 2-transform.do

Analyse data
------------

``3-analyse.do`` is another Stata do file. I takes the dataset created by ``2-transform.do`` (``data/strumia.dta``) and creates Figures 1 and 2 in Ball et al. (2020) (figures are stored in the ``figures`` directory). Execute it in Stata with the following command.

.. code-block:: stata
	
	. do 3-analyse.do

``master.sh``
-----------

``master.sh`` is a bash script that will execute ``1-import.py``, ``2-transform.do`` and ``3-analyse.do`` at the same time. It also converts the pdf figure files created by ``2-transform.do`` into png files and trims excess whitespace around the figures using the ImageMagick command ``convert``. To execute ``0-master.sh`` type the following in the Bash command line.

.. code-block:: bash

	$ sh 0-master.sh