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

#ifndef POCKETFFT32_H
#define POCKETFFT32_H

#include <stdlib.h>

/*  prior
struct cfft_plan_i_f32;
typedef struct cfft_plan_i_f32 * cfft_plan_f32;
***/
/* new: */
#define NFCT 25
typedef struct cmplx_f32 {
  float r,i;
} cmplx_f32;

typedef struct cfftp_fctdata
  {
  size_t fct;
  cmplx_f32 *tw, *tws;
  } cfftp_fctdata;


typedef struct cfftp_plan_i_f32
  {
  size_t length, nfct;
  cmplx_f32 *mem;
  cfftp_fctdata fct[NFCT];
  } cfftp_plan_i_f32;
typedef struct cfftp_plan_i_f32 * cfftp_plan_f32;

typedef struct fftblue_plan_i_f32
  {
  size_t n, n2;
  cfftp_plan_f32 plan;
  float *mem;
  float *bk, *bkf;
  } fftblue_plan_i_f32;
typedef struct fftblue_plan_i_f32 * fftblue_plan_f32;

typedef struct cfft_plan_i_f32
  {
  cfftp_plan_f32 packplan;
  fftblue_plan_f32 blueplan;
  } cfft_plan_i_f32;
typedef struct cfft_plan_i_f32 * cfft_plan_f32;

typedef struct rfftp_fctdata
  {
  size_t fct;
  float *tw, *tws;
  } rfftp_fctdata;

typedef struct rfftp_plan_i_f32
  {
  size_t length, nfct;
  float *mem;
  rfftp_fctdata fct[NFCT];
  } rfftp_plan_i_f32;
typedef struct rfftp_plan_i_f32 * rfftp_plan_f32;

typedef struct rfft_plan_i_f32
  {
  rfftp_plan_f32 packplan;
  fftblue_plan_f32 blueplan;
  } rfft_plan_i_f32;

/* end new */

cfft_plan_f32 make_cfft_plan_f32 (size_t length);
void destroy_cfft_plan_f32 (cfft_plan_f32 plan);
int cfft_backward_f32(cfft_plan_f32 plan, float c[], float fct);
int cfft_forward_f32(cfft_plan_f32 plan, float c[], float fct);
size_t cfft_length_f32(cfft_plan_f32 plan);

struct rfft_plan_i_f32;
typedef struct rfft_plan_i_f32 * rfft_plan_f32;
rfft_plan_f32 make_rfft_plan_f32 (size_t length);
void destroy_rfft_plan_f32 (rfft_plan_f32 plan);
int rfft_backward_f32(rfft_plan_f32 plan, float c[], float fct);
int rfft_forward_f32(rfft_plan_f32 plan, float c[], float fct);
size_t rfft_length_f32(rfft_plan_f32 plan);

#endif
