reset()
import sys
inputfile_name = sys.argv[1]
# inputfile_name = "ToyExample-type1-n10-seed0"
with open(inputfile_name, 'r') as inputfile:
    file_contents = inputfile.readlines()
field_line = file_contents[0].split(" : ")[1]
field_line = field_line.replace(" ", "")
if "/" in field_line:
    field_line = field_line.split("/")
    R = sage_eval(field_line[0],locals={'x':x})
    F = R.base()
    modulus_poly = R(symbolic_expression(field_line[1]))
    base_field = F.extension(modulus_poly, 'a', repr='int')
    str_to_field_element = lambda t: base_field(list(map(int, list(bin(int(t, 16))[:1:-1]))))
else:
    base_field = sage_eval(file_contents[0].split(" : ")[1])
    str_to_field_element = lambda t: base_field(t)
number_of_variables = int(file_contents[1].split(" : ")[1])
number_of_equations = int(file_contents[2].split(" : ")[1])
monomial_order = file_contents[4].split(" : ")[1]
polynomial_ring = PolynomialRing(base_field, number_of_variables, names='x', order='degrevlex')
exponents = IntegerVectors(2, number_of_variables, max_part=2).list()
quadratic_monomials = []
for e in exponents:
    quadratic_monomials.append(polynomial_ring.monomial(*e))
linear_monomials = []
for var in polynomial_ring.gens():
    linear_monomials.append(var)
monomials = quadratic_monomials + linear_monomials + [1]
monomials.sort(reverse=True)
monomials = matrix(monomials).transpose()
# coefficient_matrix = matrix(base_field, number_of_equations, number_of_variables)
coefficient_matrix = []
for i in range(7, 7 + number_of_equations):
    row = file_contents[i].replace(" ;", "")
    row = row.split(" ")
    coefficient_matrix.append(list(map(str_to_field_element, row)))
coefficient_matrix = matrix(coefficient_matrix)
polynomials = coefficient_matrix*monomials
if base_field == GF(2):
    flt = lambda x: x if (not x.is_square() or x.is_constant()) else x.variable()
    simplifier = lambda f : sum(list(map(flt, f.monomials())))
    simplified_equations = []
    for row in polynomials.rows():
        simplified_equations.append(simplifier(row[0]))
    equations = simplified_equations
    equations_str = list(map(str, equations))
else:
    equations = []
    for row in polynomials.rows():
        equations.append(row[0])
    equations_str = list(map(str, equations))
with open('equations.txt', 'w') as file:
    file.write("Base field: %s\n" % str(base_field))
    file.write("Modulus: %s\n" % str(base_field.modulus()))
    for eq in equations_str:
        file.write(eq)
        file.write('\n')
