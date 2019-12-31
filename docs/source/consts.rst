.. index::
   single: physical constants
   single: constants, physical
   single: conversion of units
   single: units, conversion of

******************
Physical Constants
******************

This module is inspired by the constants module present in CML.

The full list of constants is described briefly below.  Consult the
header files themselves for the values of the constants used in the
library.

.. index::
   single: fundamental constants
   single: constants, fundamental

Fundamental Constants
=====================

.. macro:: consts.mksa_speed_of_light

   The speed of light in vacuum, :math:`c`.

.. macro:: consts.mksa_vacuum_permeability

   The permeability of free space, :math:`\mu_0`. This constant is defined
   in the MKSA system only.

.. macro:: consts.mksa_vacuum_permittivity

   The permittivity of free space, :math:`\epsilon_0`.  This constant is
   defined in the MKSA system only.

.. macro:: consts.mksa_plancks_constant_h

   Planck's constant, :math:`h`.

.. macro:: consts.mksa_plancks_constant_hbar

   Planck's constant divided by :math:`2\pi`, :math:`\hbar`.

.. macro:: consts.num_avogadro

   Avogadro's number, :math:`N_a`.

.. macro:: consts.mksa_faraday

   The molar charge of 1 Faraday.

.. macro:: consts.mksa_boltzmann

   The Boltzmann constant, :math:`k`.

.. macro:: consts.mksa_molar_gas

   The molar gas constant, :math:`R_0`.

.. macro:: consts.mksa_standard_gas_volume

   The standard gas volume, :math:`V_0`.

.. macro:: consts.mksa_stefan_boltzmann_constant

   The Stefan-Boltzmann radiation constant, :math:`\sigma`.

.. macro:: consts.mksa_gauss

   The magnetic field of 1 Gauss.

.. index:: astronomical constants

Astronomy and Astrophysics
==========================

.. macro:: consts.mksa_astronomical_unit

   The length of 1 astronomical unit (mean earth-sun distance), :math:`au`.

.. macro:: consts.mksa_gravitational_constant

   The gravitational constant, :math:`G`.

.. macro:: consts.mksa_light_year

   The distance of 1 light-year, :math:`ly`.

.. macro:: consts.mksa_parsec

   The distance of 1 parsec, :math:`pc`.

.. macro:: consts.mksa_grav_accel

   The standard gravitational acceleration on Earth, :math:`g`.

.. macro:: consts.mksa_solar_mass

   The mass of the Sun.

.. index::
   single: atomic physics, constants
   single: nuclear physics, constants

Atomic and Nuclear Physics
==========================

.. macro:: consts.mksa_electron_charge

   The charge of the electron, :math:`e`.

.. macro:: consts.mksa_electron_volt

   The energy of 1 electron volt, :math:`eV`.

.. macro:: consts.mksa_unified_atomic_mass

   The unified atomic mass, :math:`amu`.

.. macro:: consts.mksa_mass_electron

   The mass of the electron, :math:`m_e`.

.. macro:: consts.mksa_mass_muon

   The mass of the muon, :math:`m_\mu`.

.. macro:: consts.mksa_mass_proton

   The mass of the proton, :math:`m_p`.

.. macro:: consts.mksa_mass_neutron

   The mass of the neutron, :math:`m_n`.

.. macro:: consts.num_fine_structure

   The electromagnetic fine structure constant :math:`\alpha`.

.. macro:: consts.mksa_rydberg

   The Rydberg constant, :math:`Ry`, in units of energy.  This is related to
   the Rydberg inverse wavelength :math:`R_\infty` by :math:`Ry = h c R_\infty`.

.. macro:: consts.mksa_bohr_radius

   The Bohr radius, :math:`a_0`.

.. macro:: consts.mksa_angstrom

   The length of 1 angstrom.

.. macro:: consts.mksa_barn

   The area of 1 barn.

.. macro:: consts.mksa_bohr_magneton

   The Bohr Magneton, :math:`\mu_B`.

.. macro:: consts.mksa_nuclear_magneton

   The Nuclear Magneton, :math:`\mu_N`.

.. macro:: consts.mksa_electron_magnetic_moment

   The absolute value of the magnetic moment of the electron, :math:`\mu_e`.
   The physical magnetic moment of the electron is negative.

.. macro:: consts.mksa_proton_magnetic_moment

   The magnetic moment of the proton, :math:`\mu_p`.

.. macro:: consts.mksa_thomson_cross_section

   The Thomson cross section, :math:`\sigma_T`.

.. macro:: consts.mksa_debye

   The electric dipole moment of 1 Debye, :math:`D`.

.. index:: time units

Measurement of Time
===================

.. macro:: consts.mksa_minute

   The number of seconds in 1 minute.

.. macro:: consts.mksa_hour

   The number of seconds in 1 hour.

.. macro:: consts.mksa_day

   The number of seconds in 1 day.

.. macro:: consts.mksa_week

   The number of seconds in 1 week.

.. index::
   single: imperial units
   single: units, imperial

Imperial Units
==============

.. macro:: consts.mksa_inch

   The length of 1 inch.

.. macro:: consts.mksa_foot

   The length of 1 foot.

.. macro:: consts.mksa_yard

   The length of 1 yard.

.. macro:: consts.mksa_mile

   The length of 1 mile.

.. macro:: consts.mksa_mil

   The length of 1 mil (1/1000th of an inch).

.. index:: nautical units

Speed and Nautical Units
========================

.. macro:: consts.mksa_kilometers_per_hour

   The speed of 1 kilometer per hour.

.. macro:: consts.mksa_miles_per_hour

   The speed of 1 mile per hour.

.. macro:: consts.mksa_nautical_mile

   The length of 1 nautical mile.

.. macro:: consts.mksa_fathom

   The length of 1 fathom.

.. macro:: consts.mksa_knot

   The speed of 1 knot.

.. index:: printers units

Printers Units
==============

.. macro:: consts.mksa_point

   The length of 1 printer's point (1/72 inch).

.. macro:: consts.mksa_texpoint

   The length of 1 TeX point (1/72.27 inch).

.. index:: volume units

Volume, Area and Length
=======================

.. macro:: consts.mksa_micron

   The length of 1 micron.

.. macro:: consts.mksa_hectare

   The area of 1 hectare.

.. macro:: consts.mksa_acre

   The area of 1 acre.

.. macro:: consts.mksa_liter

   The volume of 1 liter.

.. macro:: consts.mksa_us_gallon

   The volume of 1 US gallon.

.. macro:: consts.mksa_canadian_gallon

   The volume of 1 Canadian gallon.

.. macro:: consts.mksa_uk_gallon

   The volume of 1 UK gallon.

.. macro:: consts.mksa_quart

   The volume of 1 quart.

.. macro:: consts.mksa_pint

   The volume of 1 pint.

.. @node Cookery
.. @section Cookery
.. @commentindex cookery units

.. @table @commentode
.. @item consts.mksa_cup
.. The volume of 1 cup.

.. @item consts.mksa_fluid_ounce
.. The volume of 1 fluid ounce.

.. @item consts.mksa_tablespoon
.. The volume of 1 tablespoon.

.. @item consts.mksa_teaspoon
.. The volume of 1 teaspoon.
.. @end table

.. index::
   single: mass, units of
   single: weight, units of

Mass and Weight
===============

.. macro:: consts.mksa_pound_mass

   The mass of 1 pound.

.. macro:: consts.mksa_ounce_mass

   The mass of 1 ounce.

.. macro:: consts.mksa_ton

   The mass of 1 ton.

.. macro:: consts.mksa_metric_ton

   The mass of 1 metric ton (1000 kg).

.. macro:: consts.mksa_uk_ton

   The mass of 1 UK ton.

.. macro:: consts.mksa_troy_ounce

   The mass of 1 troy ounce.

.. macro:: consts.mksa_carat

   The mass of 1 carat.

.. macro:: consts.mksa_gram_force

   The force of 1 gram weight.

.. macro:: consts.mksa_pound_force

   The force of 1 pound weight.

.. macro:: consts.mksa_kilopound_force

   The force of 1 kilopound weight.

.. macro:: consts.mksa_poundal

   The force of 1 poundal.

.. index::
   single: energy, units of
   single: power, units of
   single: thermal energy, units of

Thermal Energy and Power
========================

.. macro:: consts.mksa_calorie

   The energy of 1 calorie.

.. macro:: consts.mksa_btu

   The energy of 1 British Thermal Unit, :math:`btu`.

.. macro:: consts.mksa_therm

   The energy of 1 Therm.

.. macro:: consts.mksa_horsepower

   The power of 1 horsepower.

.. index:: pressure, units of

Pressure
========

.. macro:: consts.mksa_bar

   The pressure of 1 bar.

.. macro:: consts.mksa_std_atmosphere

   The pressure of 1 standard atmosphere.

.. macro:: consts.mksa_torr

   The pressure of 1 torr.

.. macro:: consts.mksa_meter_of_mercury

   The pressure of 1 meter of mercury.

.. macro:: consts.mksa_inch_of_mercury

   The pressure of 1 inch of mercury.

.. macro:: consts.mksa_inch_of_water

   The pressure of 1 inch of water.

.. macro:: consts.mksa_psi

   The pressure of 1 pound per square inch.

.. index:: viscosity, units of

Viscosity
=========

.. macro:: consts.mksa_poise

   The dynamic viscosity of 1 poise.

.. macro:: consts.mksa_stokes

   The kinematic viscosity of 1 stokes.

.. index::
   single: light, units of
   single: illumination, units of

Light and Illumination
======================

.. macro:: consts.mksa_stilb

   The luminance of 1 stilb.

.. macro:: consts.mksa_lumen

   The luminous flux of 1 lumen.

.. macro:: consts.mksa_lux

   The illuminance of 1 lux.

.. macro:: consts.mksa_phot

   The illuminance of 1 phot.

.. macro:: consts.mksa_footcandle

   The illuminance of 1 footcandle.

.. macro:: consts.mksa_lambert

   The luminance of 1 lambert.

.. macro:: consts.mksa_footlambert

   The luminance of 1 footlambert.

.. index:: radioactivity, units of

Radioactivity
=============

.. macro:: consts.mksa_curie

   The activity of 1 curie.

.. macro:: consts.mksa_roentgen

   The exposure of 1 roentgen.

.. macro:: consts.mksa_rad

   The absorbed dose of 1 rad.

.. index:: force and energy, units of

Force and Energy
================

.. macro:: consts.mksa_newton

   The SI unit of force, 1 Newton.

.. macro:: consts.mksa_dyne

   The force of 1 Dyne = :math:`10^{-5}` Newton.

.. macro:: consts.mksa_joule

   The SI unit of energy, 1 Joule.

.. macro:: consts.mksa_erg

   The energy 1 erg = :math:`10^{-7}` Joule.

.. index::
   single: prefixes
   single: constants, prefixes

Prefixes
========

These constants are dimensionless scaling factors.

.. macro:: consts.num_yotta

   :math:`10^{24}`

.. macro:: consts.num_zetta

   :math:`10^{21}`

.. macro:: consts.num_exa

   :math:`10^{18}`

.. macro:: consts.num_peta

   :math:`10^{15}`

.. macro:: consts.num_tera

   :math:`10^{12}`

.. macro:: consts.num_giga

   :math:`10^9`

.. macro:: consts.num_mega

   :math:`10^6`

.. macro:: consts.num_kilo

   :math:`10^3`

.. macro:: consts.num_milli

   :math:`10^{-3}`

.. macro:: consts.num_micro

   :math:`10^{-6}`

.. macro:: consts.num_vsl_nano

   :math:`10^{-9}`

.. macro:: consts.num_pico

   :math:`10^{-12}`

.. macro:: consts.num_femto

   :math:`10^{-15}`

.. macro:: consts.num_atto

   :math:`10^{-18}`

.. macro:: consts.num_zepto

   :math:`10^{-21}`

.. macro:: consts.num_yocto

   :math:`10^{-24}`

Examples
========

The following program demonstrates the use of the physical constants in
a calculation.  In this case, the goal is to calculate the range of
light-travel times from Earth to Mars.

The required data is the average distance of each planet from the Sun in
astronomical units (the eccentricities and inclinations of the orbits
will be neglected for the purposes of this calculation).  The average
radius of the orbit of Mars is 1.52 astronomical units, and for the
orbit of Earth it is 1 astronomical unit (by definition).  These values
are combined with the MKSA values of the constants for the speed of
light and the length of an astronomical unit to produce a result for the
shortest and longest light-travel times in seconds.  The figures are
converted into minutes before being displayed.

.. include:: examples/consts.v
   :code:

Here is the output from the program,

.. include:: examples/consts.txt
   :code:

References and Further Reading
==============================

The authoritative sources for physical constants are the 2006 CODATA
recommended values, published in the article below. Further
information on the values of physical constants is also available from
the NIST website.

* P.J. Mohr, B.N. Taylor, D.B. Newell, "CODATA Recommended
  Values of the Fundamental Physical Constants: 2006", Reviews of
  Modern Physics, 80(2), pp. 633--730 (2008).
