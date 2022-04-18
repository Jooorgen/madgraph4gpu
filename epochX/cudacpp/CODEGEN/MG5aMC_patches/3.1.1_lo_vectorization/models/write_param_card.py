###############################################################################
#
# Copyright (c) 2010 The MadGraph5_aMC@NLO Development team and Contributors
#
# This file is a part of the MadGraph5_aMC@NLO project, an application which 
# automatically generates Feynman diagrams and matrix elements for arbitrary
# high-energy processes in the Standard Model and beyond.
#
# It is subject to the MadGraph5_aMC@NLO license which should accompany this 
# distribution.
#
# For more information, visit madgraph.phys.ucl.ac.be and amcatnlo.web.cern.ch
#
################################################################################
from __future__ import absolute_import
from __future__ import print_function
import models.model_reader as model_reader
import madgraph.core.base_objects as base_objects
import madgraph.various.misc as misc
from six.moves import range

class ParamCardWriterError(Exception):
    """ a error class for this file """

def cmp_to_key(mycmp):
    'Convert a cmp= function into a key= function'


    class K:
        def __init__(self, obj, *args):
            self.obj = obj
        def __lt__(self, other):
            return mycmp(self.obj, other.obj) < 0
        def __gt__(self, other):
            return mycmp(self.obj, other.obj) > 0
        def __eq__(self, other):
            return mycmp(self.obj, other.obj) == 0
        def __le__(self, other):
            return mycmp(self.obj, other.obj) <= 0
        def __ge__(self, other):
            return mycmp(self.obj, other.obj) >= 0
        def __ne__(self, other):
            return mycmp(self.obj, other.obj) != 0
    return K


class ParamCardWriter(object):
    """ A class for writting an update param_card for a given model """

    header = \
    "######################################################################\n" + \
    "## PARAM_CARD AUTOMATICALY GENERATED BY MG5 FOLLOWING UFO MODEL   ####\n" + \
    "######################################################################\n" + \
    "##                                                                  ##\n" + \
    "##  Width set on Auto will be computed following the information    ##\n" + \
    "##        present in the decay.py files of the model.               ##\n" + \
    '##        See  arXiv:1402.1178 for more details.                    ##\n' + \
    "##                                                                  ##\n" + \
    "######################################################################\n"
    
    sm_pdg = [1,2,3,4,5,6,11,12,13,13,14,15,16,21,22,23,24,25]
    qnumber_str ="""Block QNUMBERS %(pdg)d  # %(name)s 
        1 %(charge)g  # 3 times electric charge
        2 %(spin)d  # number of spin states (2S+1)
        3 %(color)d  # colour rep (1: singlet, 3: triplet, 8: octet)
        4 %(antipart)d  # Particle/Antiparticle distinction (0=own anti)\n"""


    def __init__(self, model, filepath=None, write_special=True):
        """ model is a valid MG5 model, filepath is the path were to write the
        param_card.dat """

        # Compute the value of all dependant parameter
        if isinstance(model, model_reader.ModelReader):
            ###self.model = model
            import copy
            self.model = copy.deepcopy(model) # workaround for https://github.com/oliviermattelaer/mg5amc_test/issues/2
        else:
            self.model = model_reader.ModelReader(model)
            self.model.set_parameters_and_couplings()

        
        assert self.model['parameter_dict']

        # Organize the data
        self.external = self.model['parameters'][('external',)]
        self.param_dict = self.create_param_dict()
        self.define_not_dep_param()
    
        if filepath:
            self.define_output_file(filepath)
            self.write_card(write_special=write_special)
    
    
    def create_param_dict(self):
        """ return {'name': parameterObject}"""
        
        out = {}
        for key, params in self.model['parameters'].items():
            for param in params:
                out[param.name] = param
                
        if 'ZERO' not in list(out.keys()):
            zero = base_objects.ModelVariable('ZERO', '0', 'real')
            out['ZERO'] = zero
        return out

    
    def define_not_dep_param(self):
        """define self.dep_mass and self.dep_width in case that they are 
        requested in the param_card.dat"""
        
        all_particles = self.model['particles']
        
        # 
        self.dep_mass, self.dep_width = [] , []
        self.duplicate_mass, self.duplicate_width = [], [] 

        def_param = [] 
        # one loop for the mass
        for p in all_particles:
            mass = self.param_dict[p["mass"]]
            if isinstance(mass, base_objects.ParamCardVariable):
                if mass.lhacode[0] != p['pdg_code']:
                    self.duplicate_mass.append((p, mass))
                    continue                    
            if mass in def_param:
                self.duplicate_mass.append((p, mass))
                continue
            elif p["mass"] != 'ZERO':
                def_param.append(mass)
            if p['mass'] not in self.external:
                self.dep_mass.append((p, mass))

        # one loop for the width
        def_param = [] 
        for p in all_particles:
            width = self.param_dict[p["width"]]
            if isinstance(width, base_objects.ParamCardVariable):
                if width.lhacode[0] != p['pdg_code']:
                    self.duplicate_width.append((p, width))
                    continue 
            if width in def_param:
                self.duplicate_width.append((p, width))
                continue
            else:
                if p["width"] != 'ZERO':
                    def_param.append(width)
            if p['width'] not in self.external:
                self.dep_width.append((p, width))

        
        
    @staticmethod
    def order_param(obj1, obj2):
        """ order parameter of a given block """
        
        block1 = obj1.lhablock.upper()
        block2 = obj2.lhablock.upper()
        
        if block1 == block2:
            pass
        elif block1 == 'DECAY':
            return 1
        elif block2 == 'DECAY':
            return -1
        elif block1 < block2:
            return -1
        elif block1 != block2:
            return 1
        
        maxlen = min([len(obj1.lhacode), len(obj2.lhacode)])

        for i in range(maxlen):
            if obj1.lhacode[i] < obj2.lhacode[i]:
                return -1
            elif obj1.lhacode[i] > obj2.lhacode[i]:
                return 1
            
        #identical up to the first finish
        if len(obj1.lhacode) > len(obj2.lhacode):
            return 1
        elif  len(obj1.lhacode) == len(obj2.lhacode):
            return 0
        else:
            return -1

    def define_output_file(self, path, mode='w'):
        """ initialize the file"""
        
        if isinstance(path, str):
            self.fsock = open(path, mode)
        else:
            self.fsock = path # prebuild file/IOstring
        
        self.fsock.write(self.header)

    def write_card(self, path=None, write_special=True):
        """schedular for writing a card"""
    
        if path:
            self.define_input_file(path)

  
        # order the parameter in a smart way
        self.external.sort(key=cmp_to_key(self.order_param))
        todo_block= ['MASS', 'DECAY'] # ensure that those two block are always written
        
        cur_lhablock = ''
        for param in self.external:
            if not write_special and param.lhablock.lower() == 'loop':
                continue
            #check if we change of lhablock
            if cur_lhablock != param.lhablock.upper(): 
                # check if some dependent param should be written
                self.write_dep_param_block(cur_lhablock)
                cur_lhablock = param.lhablock.upper()
                if cur_lhablock in todo_block:
                    todo_block.remove(cur_lhablock)
                # write the header of the new block
                self.write_block(cur_lhablock)
            #write the parameter
            self.write_param(param, cur_lhablock)
        self.write_dep_param_block(cur_lhablock)
        for cur_lhablock in todo_block:
            self.write_block(cur_lhablock)
            self.write_dep_param_block(cur_lhablock)
        self.write_qnumber()
        
    def write_block(self, name):
        """ write a comment for a block"""
        
        self.fsock.writelines(
        """\n###################################""" + \
        """\n## INFORMATION FOR %s""" % name.upper() +\
        """\n###################################\n"""
         )
        if name!='DECAY':
            self.fsock.write("""Block %s \n""" % name.lower())
            
    def write_param(self, param, lhablock):
        """ write the line corresponding to a given parameter """
    
        if hasattr(param, 'info'):
            info = param.info
        else:
            info = param.name
        if info.startswith('mdl_'):
            info = info[4:]
    
        if param.value != 'auto' and param.value.imag != 0:
            raise ParamCardWriterError('All External Parameter should be real (not the case for %s)'%param.name)

        # avoid to keep special value used to avoid restriction
        if param.value == 9.999999e-1:
            param.value = 1
        elif param.value == 0.000001e-99:
            param.value = 0
    
        # If write_special is on False, activate special handling of special parameter
        # like aS/MUR (fixed via run_card / lhapdf)
        if param.lhablock.lower() == 'sminputs' and tuple(param.lhacode) == (3,):
            info = "%s (Note that Parameter not used if you use a PDF set)" % info
         
    
    
        lhacode=' '.join(['%3s' % key for key in param.lhacode])
        if lhablock != 'DECAY':
            text = """  %s %e # %s \n""" % (lhacode, param.value.real, info) 
        elif param.value == 'auto':
            text = '''DECAY %s auto # %s \n''' % (lhacode, info)
        else:
            text = '''DECAY %s %e # %s \n''' % (lhacode, param.value.real, info)
        self.fsock.write(text)             
      
        
    def write_dep_param_block(self, lhablock):
        """writing the requested LHA parameter"""

        if lhablock == 'MASS':
            data = self.dep_mass
            #misc.sprint(data)
            prefix = " "
        elif lhablock == 'DECAY':
            data = self.dep_width
            prefix = "DECAY "
        else:
            return
        
        text = ""        
        data.sort(key= lambda el: el[0]["pdg_code"])
        for part, param in data:
            # don't write the width of ghosts particles
            if part["type"] == "ghost":
                continue
            if self.model['parameter_dict'][param.name].imag:
                raise ParamCardWriterError('All Mass/Width Parameter should be real (not the case for %s)'%param.name)
            value = complex(self.model['parameter_dict'][param.name]).real
            text += """%s %s %e # %s : %s \n""" %(prefix, part["pdg_code"], 
                        value, part["name"], param.expr.replace('mdl_',''))  
        
        # Add duplicate parameter
        if lhablock == 'MASS':
            data = self.duplicate_mass 
            name = 'mass'
        elif lhablock == 'DECAY':
            data = self.duplicate_width
            name = 'width'
    
        for part, param in data:
            if self.model['parameter_dict'][param.name].imag:
                raise ParamCardWriterError('All Mass/Width Parameter should be real')
            value = complex(self.model['parameter_dict'][param.name]).real
            text += """%s %s %e # %s : %s \n""" %(prefix, part["pdg_code"], 
                        value, part["name"], part[name].replace('mdl_',''))

        if not text:
            return
         
        pretext =  "## Dependent parameters, given by model restrictions.\n"
        pretext += "## Those values should be edited following the \n"
        pretext += "## analytical expression. MG5 ignores those values \n"
        pretext += "## but they are important for interfacing the output of MG5\n"
        pretext += "## to external program such as Pythia.\n"
        self.fsock.write(pretext + text)                
        
    
    def write_qnumber(self):
        """ write qnumber """
        
        def is_anti(logical):
            if logical:
                return 0
            else:
                return 1
        

        text = "" 
        for part in self.model['particles']:
            if part["pdg_code"] in self.sm_pdg or part["pdg_code"] < 0:
                continue
            # don't write ghosts in the QNumbers block
            #if part["type"] == 'ghost':
            #    continue
            text += self.qnumber_str % {'pdg': part["pdg_code"],
                                 'name': part["name"],
                                 'charge': 3 * part["charge"],
                                 'spin': part["spin"],
                                 'color': part["color"],
                                 'antipart': is_anti(part['self_antipart'])}

        if text:
            pretext="""#===========================================================\n"""
            pretext += """# QUANTUM NUMBERS OF NEW STATE(S) (NON SM PDG CODE)\n"""
            pretext += """#===========================================================\n\n"""
        
            self.fsock.write(pretext + text)
        
        
            
            
            
            
        
            
if '__main__' == __name__:
    ParamCardWriter('./param_card.dat', generic=True)
    print('write ./param_card.dat')
    
