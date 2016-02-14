
echo "Args: %*"
echo "Boost dir: %1"
echo "Component: %2"

%1\dist\bin\bcp.exe --boost="%1" --list "%2"