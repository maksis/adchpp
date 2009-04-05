%module pyadchpp

%{
// Python pollution
#undef socklen_t
%}

%typemap(in) std::tr1::function<void ()> {
	$1 = PyHandle($input, false);
}
%typemap(in) std::tr1::function<void (adchpp::Entity&)> {
	$1 = PyHandle($input, false);
}
%typemap(in) std::tr1::function<void (adchpp::Entity&, adchpp::AdcCommand&)> {
	$1 = PyHandle($input, false);
}
%typemap(in) std::tr1::function<void (adchpp::Entity&, int)> {
	$1 = PyHandle($input, false);
}
%typemap(in) std::tr1::function<void (adchpp::Entity&, const std::string&)> {
	$1 = PyHandle($input, false);
}
%typemap(in) std::tr1::function<void (adchpp::Entity&, adchpp::AdcCommand&, bool&)> {
	$1 = PyHandle($input, false);
}
%typemap(in) std::tr1::function<void (adchpp::Entity&, const adchpp::StringList&, bool&)> {
	$1 = PyHandle($input, false);
}

%include "adchpp.i"

%init%{
	PyEval_InitThreads();
%}
%{
struct PyGIL {
	PyGIL() { state = PyGILState_Ensure(); }
	~PyGIL() { PyGILState_Release(state); }
	PyGILState_STATE state;
};

struct PyHandle {
	PyHandle(PyObject* obj_, bool newRef) : obj(obj_) { if(!newRef) Py_XINCREF(obj); }
	PyHandle(const PyHandle& rhs) : obj(rhs.obj) { Py_XINCREF(obj); }

	PyHandle& operator=(const PyHandle& rhs) {
		Py_XDECREF(obj);
		obj = rhs.obj;
		Py_XINCREF(obj);
		return *this;
	}

	~PyHandle() { Py_XDECREF(obj); }

	bool valid() const { return obj; }

	PyObject* operator ->() { return obj; }
	operator PyObject*() { return obj; }

	static PyObject* getBool(bool v) {
		PyObject* ret = v ? Py_True : Py_False;
		Py_INCREF(ret);
		return ret;
	}

	void operator()() {
		PyGIL gil;
		PyHandle ret(PyObject_Call(obj, PyTuple_New(0), 0), true);

		if(!ret.valid()) {
			PyErr_Print();
			return;
		}
	}

	void operator()(adchpp::Entity& c) {
		PyGIL gil;
		PyObject* args(PyTuple_New(1));

		PyTuple_SetItem(args, 0, SWIG_NewPointerObj(SWIG_as_voidptr(&c), SWIGTYPE_p_adchpp__Entity, 0 |  0 ));
		PyHandle ret(PyObject_Call(obj, args, 0), true);

		if(!ret.valid()) {
			PyErr_Print();
			return;
		}
	}

	void operator()(adchpp::Entity& c, const std::string& str) {
		PyGIL gil;
		PyObject* args(PyTuple_New(2));

		PyTuple_SetItem(args, 0, SWIG_NewPointerObj(SWIG_as_voidptr(&c), SWIGTYPE_p_adchpp__Entity, 0 |  0 ));
		PyTuple_SetItem(args, 1, PyString_FromString(str.c_str()));

		PyHandle ret(PyObject_Call(obj, args, 0), true);

		if(!ret.valid()) {
			PyErr_Print();
			return;
		}
	}

	void operator()(adchpp::Entity& c, int i) {
		PyGIL gil;
		PyObject* args(PyTuple_New(2));

		PyTuple_SetItem(args, 0, SWIG_NewPointerObj(SWIG_as_voidptr(&c), SWIGTYPE_p_adchpp__Entity, 0 |  0 ));
		PyTuple_SetItem(args, 1, PyInt_FromLong(i));

		PyHandle ret(PyObject_Call(obj, args, 0), true);

		if(!ret.valid()) {
			PyErr_Print();
			return;
		}
	}

	void operator()(adchpp::Entity& c, adchpp::AdcCommand& cmd) {
		PyGIL gil;
		PyObject* args(PyTuple_New(2));

		PyTuple_SetItem(args, 0, SWIG_NewPointerObj(SWIG_as_voidptr(&c), SWIGTYPE_p_adchpp__Entity, 0 |  0 ));
		PyTuple_SetItem(args, 1, SWIG_NewPointerObj(SWIG_as_voidptr(&cmd), SWIGTYPE_p_adchpp__AdcCommand, 0 |  0 ));

		PyHandle ret(PyObject_Call(obj, args, 0), true);

		if(!ret.valid()) {
			PyErr_Print();
			return;
		}
	}

	void operator()(adchpp::Entity& c, adchpp::AdcCommand& cmd, bool& i) {
		PyGIL gil;
		PyObject* args(PyTuple_New(3));

		PyTuple_SetItem(args, 0, SWIG_NewPointerObj(SWIG_as_voidptr(&c), SWIGTYPE_p_adchpp__Entity, 0 |  0 ));
		PyTuple_SetItem(args, 1, SWIG_NewPointerObj(SWIG_as_voidptr(&cmd), SWIGTYPE_p_adchpp__AdcCommand, 0 |  0 ));
		PyTuple_SetItem(args, 2, getBool(i));

		PyHandle ret(PyObject_Call(obj, args, 0), true);

		if(!ret.valid()) {
			PyErr_Print();
			return;
		}

		if(PyInt_Check(ret)) {
			i &= static_cast<bool>(PyInt_AsLong(ret));
		}
	}

	void operator()(adchpp::Entity& c, const adchpp::StringList& cmd, bool& i) {
		PyGIL gil;
		PyObject* args(PyTuple_New(3));

		PyTuple_SetItem(args, 0, SWIG_NewPointerObj(SWIG_as_voidptr(&c), SWIGTYPE_p_adchpp__Entity, 0 |  0 ));
		PyTuple_SetItem(args, 1, SWIG_NewPointerObj(SWIG_as_voidptr(&cmd), SWIGTYPE_p_std__vectorT_std__string_std__allocatorT_std__string_t_t, 0 |  0 ));
		PyTuple_SetItem(args, 2, getBool(i));

		PyHandle ret(PyObject_Call(obj, args, 0), true);

		if(PyInt_Check(ret)) {
			i &= static_cast<bool>(PyInt_AsLong(ret));
		}
	}

private:
	PyObject* obj;
};
%}

