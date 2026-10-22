package com.app.lab5decla;

import alice.tuprolog.Prolog;
import alice.tuprolog.SolveInfo;
import alice.tuprolog.Struct;
import alice.tuprolog.Term;
import alice.tuprolog.Theory;

import java.io.InputStream;

public class Connection {
    private final Prolog engine = new Prolog();

    public Connection() throws Exception {
        try (InputStream in = getClass().getResourceAsStream("/calculo.pl"))
        {
            if (in == null) throw new IllegalStateException("No se encontro calculo.pl");
                    engine.setTheory(new Theory(in));
        }
    }
    public String consultar(String predicado, String expresion) throws
            Exception {
        SolveInfo info = engine.solve(predicado + "(x, " + expresion + ", R0), simplificar(R0, R).");
        return info.isSuccess() ? formatear(info.getTerm("R")) : "Sin solución para esa expresión";
    }

    // Convierte el termino Prolog a notacion matematica infija legible
    private static String formatear(Term t) {
        return render(t, 1000);
    }

    private static String render(Term t, int ctx) {
        t = t.getTerm();
        if (t instanceof Struct s) {
            String op = s.getName();
            int ar = s.getArity();
            if (ar == 2 && prioridad(op) > 0) {
                int p = prioridad(op);
                String izq = render(s.getArg(0), p);
                String der = render(s.getArg(1), p - 1);
                String sep = (op.equals("+") || op.equals("-")) ? " " + op + " " : op;
                String texto = izq + sep + der;
                return p > ctx ? "(" + texto + ")" : texto;
            }
            if (ar == 1) {
                return op + "(" + render(s.getArg(0), 1000) + ")";
            }
            if (ar == 0) {
                return op;
            }
        }
        return t.toString();
    }

    private static int prioridad(String op) {
        return switch (op) {
            case "+", "-" -> 500;
            case "*", "/" -> 400;
            case "^" -> 200;
            default -> 0;
        };
    }
}
