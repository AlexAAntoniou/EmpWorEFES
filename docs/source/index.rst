.. _index:

.. Kiln documentation master file, created by
   sphinx-quickstart on Tue Jul 24 21:20:29 2012.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Kiln documentation
==================

Kiln is an open source multi-platform framework for building and
deploying complex websites whose source content is primarily
in XML. It brings together various independent software components,
with `Apache Cocoon`_ at their centre, into an integrated whole that
provides the infrastructure and base functionality for such sites.

Kiln is developed and maintained by a team at the `Department of
Digital Humanities`_ (DDH), King’s College London. Over the past years
and versions, Kiln (formerly called `xMod`_) has been used to generate
more than 50 websites which have very different source materials and
customised functionality. Since DDH has in-house guidelines for using
`TEI P5`_ to create websites, Kiln makes use of certain TEI markup
conventions. However, it has been adapted to work on a variety of
flavours of TEI and other XML vocabularies, and has been used to
publish data held in relational databases.

Support
-------

See our `issue tracker`_\.

Requirements
------------

Java 1.5+ (untested with 1.7).

Contents
--------

.. toctree::
    :maxdepth: 2

    quickstart
    structure
    components
    navigation
    running
    templating
    searching
    rdf
    projects

.. _Apache Cocoon: http://cocoon.apache.org/2.1/
.. _xMod: http://www.cch.kcl.ac.uk/xmod/
.. _Department of Digital Humanities: http://www.kcl.ac.uk/artshums/depts/ddh/
.. _TEI P5: http://www.tei-c.org/release/doc/tei-p5-doc/en/html/index-toc.html
.. _issue tracker: https://github.com/kcl-ddh/kiln/issues
