# Constants

This module provides a collection of physical constants in the MKSA system.

The constants are defined in the module files themselves, and are not imported by default.

## Usage

```v
import vsl.consts

println(consts.mksa_speed_of_light)
```

## Fundamental Constants

```
consts.mksa_speed_of_light
```

The speed of light in vacuum.

```
consts.mksa_vacuum_permeability
```

The permeability of free space, `μ_0`. This constant is defined
in the MKSA system only.

```
consts.mksa_vacuum_permittivity
```

The permittivity of free space, `\epsilon_0`. This constant is
defined in the MKSA system only.

```
consts.mksa_plancks_constant_h
```

Planck's constant, `h`.

```
consts.mksa_plancks_constant_hbar
```

Planck's constant divided by `2\pi`, `\hbar`.

```
consts.num_avogadro
```

Avogadro's number, `N_a`.

```
consts.mksa_faraday
```

The molar charge of 1 Faraday.

```
consts.mksa_boltzmann
```

The Boltzmann constant, `k`.

```
consts.mksa_molar_gas
```

The molar gas constant, `R_0`.

```
consts.mksa_standard_gas_volume
```

The standard gas volume, `V_0`.

```
consts.mksa_stefan_boltzmann_constant
```

The Stefan-Boltzmann radiation constant, `\sigma`.

```
consts.mksa_gauss
```

The magnetic field of 1 Gauss.

# Astronomy and Astrophysics

```
consts.mksa_astronomical_unit
```

The length of 1 astronomical unit (mean earth-sun distance), `au`.

```
consts.mksa_gravitational_constant
```

The gravitational constant, `G`.

```
consts.mksa_light_year
```

The distance of 1 light-year, `ly`.

```
consts.mksa_parsec
```

The distance of 1 parsec, `pc`.

```
consts.mksa_grav_accel
```

The standard gravitational acceleration on Earth, `g`.

```
consts.mksa_solar_mass
```

The mass of the Sun.

# Atomic and Nuclear Physics

```
consts.mksa_electron_charge
```

The charge of the electron, `e`.

```
consts.mksa_electron_volt
```

The energy of 1 electron volt, `eV`.

```
consts.mksa_unified_atomic_mass
```

The unified atomic mass, `amu`.

```
consts.mksa_mass_electron
```

The mass of the electron, `m_e`.

```
consts.mksa_mass_muon
```

The mass of the muon, `m_μ`.

```
consts.mksa_mass_proton
```

The mass of the proton, `m_p`.

```
consts.mksa_mass_neutron
```

The mass of the neutron, `m_n`.

```
consts.num_fine_structure
```

The electromagnetic fine structure constant `\alpha`.

```
consts.mksa_rydberg
```

The Rydberg constant, `Ry`, in units of energy. This is related to
the Rydberg inverse wavelength `R_\infty` by `Ry = h c R_\infty`.

```
consts.mksa_bohr_radius
```

The Bohr radius, `a_0`.

```
consts.mksa_angstrom
```

The length of 1 angstrom.

```
consts.mksa_barn
```

The area of 1 barn.

```
consts.mksa_bohr_magneton
```

The Bohr Magneton, `μ_B`.

```
consts.mksa_nuclear_magneton
```

The Nuclear Magneton, `μ_N`.

```
consts.mksa_electron_magnetic_moment
```

The absolute value of the magnetic moment of the electron, `μ_e`.
The physical magnetic moment of the electron is negative.

```
consts.mksa_proton_magnetic_moment
```

The magnetic moment of the proton, `μ_p`.

```
consts.mksa_thomson_cross_section
```

The Thomson cross section, `\sigma_T`.

```
consts.mksa_debye
```

The electric dipole moment of 1 Debye, `D`.

# Measurement of Time

```
consts.mksa_minute
```

The number of seconds in 1 minute.

```
consts.mksa_hour
```

The number of seconds in 1 hour.

```
consts.mksa_day
```

The number of seconds in 1 day.

```
consts.mksa_week
```

The number of seconds in 1 week.

# Imperial Units

```
consts.mksa_inch
```

The length of 1 inch.

```
consts.mksa_foot
```

The length of 1 foot.

```
consts.mksa_yard
```

The length of 1 yard.

```
consts.mksa_mile
```

The length of 1 mile.

```
consts.mksa_mil
```

The length of 1 mil (1/1000th of an inch).

# Speed and Nautical Units

```
consts.mksa_kilometers_per_hour
```

The speed of 1 kilometer per hour.

```
consts.mksa_miles_per_hour
```

The speed of 1 mile per hour.

```
consts.mksa_nautical_mile
```

The length of 1 nautical mile.

```
consts.mksa_fathom
```

The length of 1 fathom.

```
consts.mksa_knot
```

The speed of 1 knot.

# Printers Units

```
consts.mksa_point
```

The length of 1 printer's point (1/72 inch).

```
consts.mksa_texpoint
```

The length of 1 TeX point (1/72.27 inch).

# Volume, Area and Length

```
consts.mksa_micron
```

The length of 1 micron.

```
consts.mksa_hectare
```

The area of 1 hectare.

```
consts.mksa_acre
```

The area of 1 acre.

```
consts.mksa_liter
```

The volume of 1 liter.

```
consts.mksa_us_gallon
```

The volume of 1 US gallon.

```
consts.mksa_canadian_gallon
```

The volume of 1 Canadian gallon.

```
consts.mksa_uk_gallon
```

The volume of 1 UK gallon.

```
consts.mksa_quart
```

The volume of 1 quart.

```
consts.mksa_pint
```

The volume of 1 pint.

# Mass and Weight

```
consts.mksa_pound_mass
```

The mass of 1 pound.

```
consts.mksa_ounce_mass
```

The mass of 1 ounce.

```
consts.mksa_ton
```

The mass of 1 ton.

```
consts.mksa_metric_ton
```

The mass of 1 metric ton (1000 kg).

```
consts.mksa_uk_ton
```

The mass of 1 UK ton.

```
consts.mksa_troy_ounce
```

The mass of 1 troy ounce.

```
consts.mksa_carat
```

The mass of 1 carat.

```
consts.mksa_gram_force
```

The force of 1 gram weight.

```
consts.mksa_pound_force
```

The force of 1 pound weight.

```
consts.mksa_kilopound_force
```

The force of 1 kilopound weight.

```
consts.mksa_poundal
```

The force of 1 poundal.

# Thermal Energy and Power

```
consts.mksa_calorie
```

The energy of 1 calorie.

```
consts.mksa_btu
```

The energy of 1 British Thermal Unit, `btu`.

```
consts.mksa_therm
```

The energy of 1 Therm.

```
consts.mksa_horsepower
```

The power of 1 horsepower.

# Pressure

```
consts.mksa_bar
```

The pressure of 1 bar.

```
consts.mksa_std_atmosphere
```

The pressure of 1 standard atmosphere.

```
consts.mksa_torr
```

The pressure of 1 torr.

```
consts.mksa_meter_of_mercury
```

The pressure of 1 meter of mercury.

```
consts.mksa_inch_of_mercury
```

The pressure of 1 inch of mercury.

```
consts.mksa_inch_of_water
```

The pressure of 1 inch of water.

```
consts.mksa_psi
```

The pressure of 1 pound per square inch.

# Viscosity

```
consts.mksa_poise
```

The dynamic viscosity of 1 poise.

```
consts.mksa_stokes
```

The kinematic viscosity of 1 stokes.

# Light and Illumination

```
consts.mksa_stilb
```

The luminance of 1 stilb.

```
consts.mksa_lumen
```

The luminous flux of 1 lumen.

```
consts.mksa_lux
```

The illuminance of 1 lux.

```
consts.mksa_phot
```

The illuminance of 1 phot.

```
consts.mksa_footcandle
```

The illuminance of 1 footcandle.

```
consts.mksa_lambert
```

The luminance of 1 lambert.

```
consts.mksa_footlambert
```

The luminance of 1 footlambert.

# Radioactivity

```
consts.mksa_curie
```

The activity of 1 curie.

```
consts.mksa_roentgen
```

The exposure of 1 roentgen.

```
consts.mksa_rad
```

The absorbed dose of 1 rad.

# Force and Energy

```
consts.mksa_newton
```

The SI unit of force, 1 Newton.

```
consts.mksa_dyne
```

The force of 1 Dyne = `10^{-5}` Newton.

```
consts.mksa_joule
```

The SI unit of energy, 1 Joule.

```
consts.mksa_erg
```

The energy 1 erg = `10^{-7}` Joule.

# Prefixes

These constants are dimensionless scaling factors.

```
consts.num_yotta
```

`10^{24}`

```
consts.num_zetta
```

`10^{21}`

```
consts.num_exa
```

`10^{18}`

```
consts.num_peta
```

`10^{15}`

```
consts.num_tera
```

`10^{12}`

```
consts.num_giga
```

`10^9`

```
consts.num_mega
```

`10^6`

```
consts.num_kilo
```

`10^3`

```
consts.num_milli
```

`10^{-3}`

```
consts.num_micro
```

`10^{-6}`

```
consts.num_vsl_nano
```

`10^{-9}`

```
consts.num_pico
```

`10^{-12}`

```
consts.num_femto
```

`10^{-15}`

```
consts.num_atto
```

`10^{-18}`

```
consts.num_zepto
```

`10^{-21}`

```
consts.num_yocto
```

`10^{-24}`

# Examples

The following program demonstrates the use of the physical constants in
a calculation. In this case, the goal is to calculate the range of
light-travel times from Earth to Mars.

The required data is the average distance of each planet from the Sun in
astronomical units (the eccentricities and inclinations of the orbits
will be neglected for the purposes of this calculation). The average
radius of the orbit of Mars is 1.52 astronomical units, and for the
orbit of Earth it is 1 astronomical unit (by definition). These values
are combined with the MKSA values of the constants for the speed of
light and the length of an astronomical unit to produce a result for the
shortest and longest light-travel times in seconds. The figures are
converted into minutes before being displayed.

```v
module main

import vsl.consts

c := consts.mksa_speed_of_light
au := consts.mksa_astronomical_unit
minutes := consts.mksa_minute // distance stored in meters
r_earth := 1.0 * au
r_mars := 1.52 * au
t_min := (r_mars - r_earth) / c
t_max := (r_mars + r_earth) / c
min := t_min / minutes
max := t_max / minutes
println('light travel time from Earth to Mars:')
println('minimum = ${min} minutes')
println('maximum = ${max} minutes')
```

will print

```
light travel time from Earth to Mars:
minimum = 4.3 minutes
maximum = 21.0 minutes
```

## References and Further Reading

The authoritative sources for physical constants are the 2006 CODATA
recommended values, published in the article below. Further
information on the values of physical constants is also available from
the NIST website.

- P.J. Mohr, B.N. Taylor, D.B. Newell, "CODATA Recommended
  Values of the Fundamental Physical Constants: 2006", Reviews of
  Modern Physics, 80(2), pp. 633--730 (2008).
