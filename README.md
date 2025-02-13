# Lua

This is a repository containing a universal Lua CMakeLists.txt.

Builds all versions of lua
Has rules to install versions
Has various extensions.


powershell notes:

git show lx/5.5/feature/natvis | Set-Content -Encoding utf8 natvis.patch  
git merge-base --is-ancestor <maybe-ancestor-commit> <descendant-commit>

cmake -B build -D CMAKE_BUILD_TYPE=Release -D LUA_PROJECT_NAME=lua -D LUA_REPOSITORY_TAG=v5.2.3

$configs = "Release", "Debug"
$projects = "lua", "lx"
$versions = "5.0", "5.1", "5.2", "5.3", "5.4", "5.5"
$lua_source = "."
$lua_build = "build"

foreach ($config in $configs) {
  foreach ($project in $projects) {
    foreach ($version in $versions) {
      $branch = "$project/$version/master"
      git show-ref --quiet refs/heads/$branch
      if ($?) {
        echo "---"
        echo "# $project | $version | $config"
        echo "---"
        echo "cmake -S $lua_source -B $lua_build -D LUA_PROJECT_NAME=$project -D LUA_REF=$branch"
        cmake -S $lua_source -B $lua_build -D LUA_PROJECT_NAME=$project -D LUA_REF=$branch
        echo "cmake --build $lua_build --config $config"
        cmake --build $lua_build --config $config
      }
    }
  }
}

