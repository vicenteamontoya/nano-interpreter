module Language.Nano.Eval
  ( execFile, execString, execExpr
  , eval, lookupId, prelude
  , parse
  , env0
  )
  where

import Control.Exception (throw, catch)
import Language.Nano.Types
import Language.Nano.Parser ( parseExpr )

--------------------------------------------------------------------------------
execFile :: FilePath -> IO Value
--------------------------------------------------------------------------------
execFile f = (readFile f >>= execString) `catch` exitError
--------------------------------------------------------------------------------
execString :: String -> IO Value
--------------------------------------------------------------------------------
execString s = execExpr (parseExpr s) `catch` exitError
--------------------------------------------------------------------------------
execExpr :: Expr -> IO Value
--------------------------------------------------------------------------------
execExpr e = return (eval prelude e) `catch` exitError
--------------------------------------------------------------------------------
parse :: String -> Expr
--------------------------------------------------------------------------------
parse = parseExpr
exitError :: Error -> IO Value
exitError (Error msg) = return (VErr msg)
--------------------------------------------------------------------------------
eval :: Env -> Expr -> Value

eval _ (EInt n)              = VInt n
eval _ (EBool b)             = VBool b
eval _ ENil                  = VNil 
eval env (EVar x)            = lookupId x env
eval env (EBin op e1 e2)     = evalOp op v1 v2
  where
    v1                       = eval env e1
    v2                       = eval env e2
eval env (EIf b x y)         = if b' then eval env x else eval env y
  where
    (VBool b')               = eval env b
    ------------------------------------
eval env (ELet x e1 e2)      = eval env' e2
  where
    v                        = eval env e1
    env'                     = (x,v) : env
    -------------------------------------
eval env (ELam x body)       = VClos env x body
eval env (EApp (EVar "head") list) = head (eval env list)
  where
    VPrim head                 = lookupId "head" env

eval env (EApp (EVar "tail") list) = tail (eval env list)
  where
    VPrim tail                 = lookupId "tail" env

eval env (EApp (EVar f) arg) = eval env'' body
  where
    clos@(VClos env' x body) = eval env (EVar f)
    vArg                     = eval env arg
    env''                    = (f,clos) : (x, vArg): env'

eval env (EApp fun arg)      = eval env'' body
  where
    VClos env' x body        = eval env fun
    vArg                     = eval env arg
    env''                    = (x, vArg) : env'

--------------------------------------------------------------------------------
evalOp :: Binop -> Value -> Value -> Value

evalOp Plus (VInt x) (VInt y)            = VInt (x + y)
evalOp Minus (VInt x) (VInt y)           = VInt (x - y)
evalOp Mul (VInt x) (VInt y)             = VInt (x * y)
evalOp Div (VInt x) (VInt y) | y /= 0    = VInt (x `div` y) 
                             | otherwise = throw (Error "cannot divide by 0")
evalOp Eq (VInt x) (VInt y)              = VBool (x == y)
evalOp Eq (VBool x) (VBool y)            = VBool (x == y)
evalOp Eq (VCons x xs) (VCons y ys)      = evalOp And (evalOp Eq x y) (evalOp Eq xs ys)
evalOp Eq (VCons _ _) VNil               = VBool False
evalOp Eq VNil (VCons _ _)               = VBool False
evalOp Eq VNil VNil                      = VBool True
evalOp Ne x y                            = VBool (not b)
  where
    VBool b                              = evalOp Eq x y
evalOp Lt (VInt x) (VInt y)              = VBool (x < y)
evalOp Le (VInt x) (VInt y)              = VBool (x <= y)
evalOp And (VBool x) (VBool y)           = VBool (x && y)
evalOp Or (VBool x) (VBool y)            = VBool (x || y)
evalOp Cons x VNil                       = VCons x VNil
evalOp Cons x (VCons y z)                = VCons x (VCons y z)
evalOp x y z                             = throw (Error ("type error: binop: " ++ show x ++ ":" ++ show y ++ "," ++ show z) )
--------------------------------------------------------------------------------
lookupId :: Id -> Env -> Value

lookupId id []                     = throw (Error ("unbound variable: " ++ id))
lookupId id ((x,y):xs) | id == x   = y
                       | otherwise = lookupId id xs

prelude :: Env
prelude = [("head", VPrim head), ("tail", VPrim tail)]
  where
    head :: Value -> Value
    head (VCons x _) = x
    head _           = throw (Error "type error: not a list")
    tail :: Value -> Value
    tail (VCons _ xs) = xs
    tail _            = throw (Error "type error: not a list")

env0 :: Env
env0 =  [ ("z1", VInt 0)
        , ("x" , VInt 1)
        , ("y" , VInt 2)
        , ("z" , VInt 3)
        , ("z1", VInt 4)
        ]
--------------------------------------------------------------------------------
