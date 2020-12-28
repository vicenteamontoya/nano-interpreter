{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_hw4_nano (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/vicenteamontoya/Documents/UCSD/cse130/04-nano-LooneyVicente/.stack-work/install/x86_64-osx/bb201a6b29c0d28a7ec798b947c08ba9b1a8ec0b8d1ce82a79649091112bdf5a/8.6.5/bin"
libdir     = "/Users/vicenteamontoya/Documents/UCSD/cse130/04-nano-LooneyVicente/.stack-work/install/x86_64-osx/bb201a6b29c0d28a7ec798b947c08ba9b1a8ec0b8d1ce82a79649091112bdf5a/8.6.5/lib/x86_64-osx-ghc-8.6.5/hw4-nano-0.1.0.0-17EgI5vDzoH8bevKdqtqC5-test"
dynlibdir  = "/Users/vicenteamontoya/Documents/UCSD/cse130/04-nano-LooneyVicente/.stack-work/install/x86_64-osx/bb201a6b29c0d28a7ec798b947c08ba9b1a8ec0b8d1ce82a79649091112bdf5a/8.6.5/lib/x86_64-osx-ghc-8.6.5"
datadir    = "/Users/vicenteamontoya/Documents/UCSD/cse130/04-nano-LooneyVicente/.stack-work/install/x86_64-osx/bb201a6b29c0d28a7ec798b947c08ba9b1a8ec0b8d1ce82a79649091112bdf5a/8.6.5/share/x86_64-osx-ghc-8.6.5/hw4-nano-0.1.0.0"
libexecdir = "/Users/vicenteamontoya/Documents/UCSD/cse130/04-nano-LooneyVicente/.stack-work/install/x86_64-osx/bb201a6b29c0d28a7ec798b947c08ba9b1a8ec0b8d1ce82a79649091112bdf5a/8.6.5/libexec/x86_64-osx-ghc-8.6.5/hw4-nano-0.1.0.0"
sysconfdir = "/Users/vicenteamontoya/Documents/UCSD/cse130/04-nano-LooneyVicente/.stack-work/install/x86_64-osx/bb201a6b29c0d28a7ec798b947c08ba9b1a8ec0b8d1ce82a79649091112bdf5a/8.6.5/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "hw4_nano_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "hw4_nano_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "hw4_nano_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "hw4_nano_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "hw4_nano_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "hw4_nano_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
