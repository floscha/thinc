from cymem.cymem cimport Pool
from libc.string cimport memset

from .typedefs cimport weight_t, atom_t
from .structs cimport FeatureC, ExampleC
from .features cimport Extracter 
from .model cimport Model
from .update cimport Updater


cdef int arg_max(const weight_t* scores, const int n_classes) nogil

cdef int arg_max_if_true(const weight_t* scores, const int* is_valid,
                         const int n_classes) nogil

cdef int arg_max_if_zero(const weight_t* scores, const weight_t* costs,
                         const int n_classes) nogil


cdef class Example:
    cdef Pool mem
    cdef ExampleC c
    cdef public int[:] is_valid
    cdef public weight_t[:] costs
    cdef public atom_t[:] atoms
    cdef public weight_t[:] embeddings
    cdef public weight_t[:] scores

    @staticmethod
    cdef inline ExampleC init(Pool mem, int nr_class, int nr_atom,
            int nr_feat, int nr_embed) except *:
        is_valid = <int*>mem.alloc(nr_class, sizeof(int))
        memset(is_valid, 1, sizeof(is_valid[0]) * nr_class)
        return ExampleC(
            is_valid = is_valid,
            costs = <weight_t*>mem.alloc(nr_class, sizeof(weight_t)),
            atoms = <atom_t*>mem.alloc(nr_atom, sizeof(atom_t)),
            features = <FeatureC*>mem.alloc(nr_feat, sizeof(FeatureC)),
            scores = <weight_t*>mem.alloc(nr_class, sizeof(weight_t)),
            
            gradient = NULL,
            fwd_state = NULL,
            bwd_state = NULL,

            nr_class = nr_class,
            nr_atom = nr_atom,
            nr_feat = nr_feat,
            guess = 0,
            best = 0,
            cost = 0)


cdef class Learner:
    cdef readonly Extracter extracter
    cdef readonly Model model
    cdef readonly Updater updater
    cdef readonly int nr_class
    cdef readonly int nr_atom
    cdef readonly int nr_templ
    cdef readonly int nr_embed

    cdef ExampleC allocate(self, Pool mem) except *

    cdef void set_prediction(self, ExampleC* eg) except *

    cdef void set_costs(self, ExampleC* eg, int gold) except *

    cdef void update(self, ExampleC* eg) except *


cdef class AveragedPerceptron(Learner):
    pass
