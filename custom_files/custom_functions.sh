cpx(){
  if [ "$#" -ne 1 ]; then
    echo "Usage: cpx <file.cpp>"
  else
    g++ -Wall  -fsanitize=address -fsanitize=undefined -ggdb3  $1; ./a.out
  fi
}

debug(){
  if [ "$#" -ne 1 ]; then
    echo "Usage: cpx <file.cpp>"
  else
    name=$(echo $1 | cut -f 1 -d '.')
    g++ -Wall -ggdb3  $1 -o $name;
    valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out-$name.txt ./$name
  fi
}

grun(){
	if [ "$#" -ne 1 ]; then
    echo "Usage: cpx <file.cpp>"
  else
		g++ $1 && ./a.out
  fi
}

gpush(){
	if [ "$#" -ne 1 ]; then
		echo "Usage: gpush <commit string> <branch> <ref>"
	else
		git add .;
		git commit -m $1;
		git push ${3:-"origin"} ${2:-"main"};
	fi
}

rv(){
	if [[ ($# -eq 1 || ($# -eq 2 && $2 =~ "*.vcd") ) && $1 =~ "*.v" ]]; then
		echo "Usage: rv <modulne> [OPTIONS] <vcd file (default dump.vcd)>"
	else
		iverilog -g2012 $1;
		vvp a.out;
		gtkwave ${2:-"dump.vcd"};
		rm a.out
		rm $2
	fi
}
