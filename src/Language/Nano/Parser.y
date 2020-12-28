{
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE PartialTypeSignatures #-}

module Language.Nano.Parser (
    parseExpr
  , parseTokens
  ) where

import Language.Nano.Lexer
import Language.Nano.Types hiding (Nano (..))
import Control.Monad.Except
import Control.Exception

}

-- Entry point
%name top

-- Lexer structure
%tokentype { Token }

-- Parser monad
%monad { Except String } { (>>=) } { return }
%error { parseError }

-- Token Names
%token
    let   { LET _    }
    true  { TRUE _   }
    false { FALSE _  }
    in    { IN _     }
    if    { IF _     }
    then  { THEN _   }
    else  { ELSE _   }
    TNUM  { NUM _ $$ }
    ID    { ID _ $$  }
    '\\'  { LAM _    }
    '->'  { ARROW _  }
    '='   { EQB _    }
    '+'   { PLUS _   }
    '-'   { MINUS _  }
    '*'   { MUL _    }
    '&&'  { AND _    }
    '||'  { OR  _    }
    '=='  { EQL _    }
    '/='  { NEQ _    }
    '<'   { LESS _   }
    '<='  { LEQ _    }
    ':'   { COLON _  }
    '('   { LPAREN _ }
    ')'   { RPAREN _ }
    '['   { LBRAC _  }
    ']'   { RBRAC _  }
    ','   { COMMA _  }
    '/'   { DIV _    }

-- Operators
%right in
%nonassoc '=' if then else
%right '->'
%left '||'
%left '&&'
%nonassoc '==' '/=' '<' '<='
%right ':'
%left '+' '-'
%left '*' '/'
%%

Top  : ID '=' Expr1                           { $3 }
     | Expr1                                  { $1 }

Expr1 : let ID '=' Expr1 in Expr1             { ELet $2 $4 $6 }
      | let ID Id '=' Expr1 in Expr1          { ELet $2 (mkLam $3 $5) $7 }
      | '\\' ID '->' Expr1                    { ELam $2 $4 }
      | if Expr1 then Expr1 else Expr1        { EIf $2 $4 $6 }
      | Expr1 '+' Expr1                       { EBin Plus $1 $3 }
      | Expr1 '-' Expr1                       { EBin Minus $1 $3 }
      | Expr1 '*' Expr1                       { EBin Mul $1 $3 }
      | Expr1 '/' Expr1                       { EBin Div $1 $3 }
      | Expr1 '<' Expr1                       { EBin Lt $1 $3 }
      | Expr1 '<=' Expr1                      { EBin Le $1 $3 }
      | Expr1 '==' Expr1                      { EBin Eq $1 $3 }
      | Expr1 '/=' Expr1                      { EBin Ne $1 $3 }
      | Expr1 '||' Expr1                      { EBin Or $1 $3 }
      | Expr1 '&&' Expr1                      { EBin And $1 $3 }
      | '[' EList ']'                         { $2 }
      | Expr1 ':' Expr1                       { EBin Cons $1 $3 }
      | Expr2                                 { $1 }

Expr2 : Expr2 Expr3                           { EApp $1 $2 }
      | Expr3                                 { $1 }

Expr3 : TNUM                                  { EInt $1 }
      | ID                                    { EVar $1 }
      | true                                  { EBool True }
      | false                                 { EBool False }
      | '(' Expr1 ')'                         { $2 }
      | '[' ']'                               { ENil }
     
Id : ID                                       { ($1: [])     }
   | ID Id                                    { ($1: $2)     }


EList : Expr1 ',' EList                       { EBin Cons $1 $3 }
      | Expr1                                 { EBin Cons $1 ENil }

{
mkLam :: [Id] -> Expr -> Expr
mkLam []     e = e
mkLam (x:xs) e = ELam x (mkLam xs e)

parseError :: [Token] -> Except String a
parseError (l:ls) = throwError (show l)
parseError []     = throwError "Unexpected end of Input"

parseExpr :: String -> Expr
parseExpr s = case parseExpr' s of
                Left msg -> throw (Error ("parse error:" ++ msg))
                Right e  -> e

parseExpr' input = runExcept $ do
   tokenStream <- scanTokens input
   top tokenStream

parseTokens :: String -> Either String [Token]
parseTokens = runExcept . scanTokens
}
   