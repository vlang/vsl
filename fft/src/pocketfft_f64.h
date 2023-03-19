/*
 * This file is part of pocketfft.
 * Licensed under a 3-clause BSD style license - see LICENSE.md
 */

/*! \file pocketfft.h
 *  Public interface of the pocketfft library
 *
 *  Copyright (C) 2008-2018 Max-Planck-Society
 *  \author Martin Reinecke
 */

#ifndef POCKETFFT64_H
#define POCKETFFT64_H

#include <stdlib.h>

/* new: */
#define NFCT 25
typedef struct cmplx_f64 {
  double r,i;
} cmplx_f64;

typedef struct cfftp_fctdata_f64
  {
  size_t fct;
  cmplx_f64 *tw, *tws;
  } cfftp_fctdata_f64;


typedef struct cfftp_plan_i_f64
  {
  size_t length, nfct;
  cmplx_f64 *mem;
  cfftp_fctdata_f64 fct[NFCT];
  } cfftp_plan_i_f64;
typedef struct cfftp_plan_i_f64 * cfftp_plan_f64;

typedef struct fftblue_plan_i_f64
  {
  size_t n, n2;
  cfftp_plan_f64 plan;
  double *mem;
  double *bk, *bkf;
  } fftblue_plan_i_f64;
typedef struct fftblue_plan_i_f64 * fftblue_plan_f64;

typedef struct cfft_plan_i_f64
  {
  cfftp_plan_f64 packplan;
  fftblue_plan_f64 blueplan;
  } cfft_plan_i_f64;
typedef struct cfft_plan_i_f64 * cfft_plan_f64;

typedef struct rfftp_fctdata_f64
  {
  size_t fct;
  double *tw, *tws;
  } rfftp_fctdata_f64;

typedef struct rfftp_plan_i_f64
  {
  size_t length, nfct;
  double *mem;
  rfftp_fctdata_f64 fct[NFCT];
  } rfftp_plan_i_f64;
typedef struct rfftp_plan_i_f64 * rfftp_plan_f64;

typedef struct rfft_plan_i_f64
  {
  rfftp_plan_f64 packplan;
  fftblue_plan_f64 blueplan;
  } rfft_plan_i_f64;

/* end new */

cfft_plan_f64 make_cfft_plan_f64 (size_t length);
void destroy_cfft_plan_f64 (cfft_plan_f64 plan);
int cfft_backward_f64(cfft_plan_f64 plan, double c[], double fct);
int cfft_forward_f64(cfft_plan_f64 plan, double c[], double fct);
size_t cfft_length_f64(cfft_plan_f64 plan);

struct rfft_plan_i_f64;
typedef struct rfft_plan_i_f64 * rfft_plan_f64;
rfft_plan_f64 make_rfft_plan_f64 (size_t length);
void destroy_rfft_plan_f64 (rfft_plan_f64 plan);
int rfft_backward_f64(rfft_plan_f64 plan, double c[], double fct);
int rfft_forward_f64(rfft_plan_f64 plan, double c[], double fct);
size_t rfft_length_f64(rfft_plan_f64 plan);

#endif
