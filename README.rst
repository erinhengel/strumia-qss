Replication files for Ball et al. (2020)
========================================

Data and replication files for all analyses presented Ball et al. (2020) 'Commentary on "Gender Issues in Fundamental Physics: A Bibliometric Analysis", Alessandro Strumia'.

Import data
-------------------------------

`1-import.py` imports the raw InSpire data (`data/InSpire.dat`), merges it with data on authors' gender (`data/AuthoID2Gender.nb`) and creates a single SQLite database file (`data/strumia.db`; see `data/schema.sql` for database structure). Execute it with the following command.

.. code-block:: bash

	$ python 1-import.py

Transform data
---------------------------

`2-transform.do` imports and merges data from various tables in `data/strumia.db`. It generates a single Stata data file containing one observation per article (`data/strumia.dta`). Execute it with the following command.

.. code-block:: bash

	$ stata-mp -s 2-transform.do

Analyse data
------------

`3-analyse.do` uses `data/strumia.dta` to create Figures 1 and 2 in Ball et al. (2020). Execute it with the following command.

.. code-block:: bash
	
	$ stata-mp -s 3-analyse.do

`master.sh`
-----------

To execute `1-import.py`, `2-transform.do` and `3-analyse.do` all at the same time execute the `0-master.sh` script:

.. code-block:: bash

	$ sh 0-master.sh