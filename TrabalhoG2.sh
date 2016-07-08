#!/bin/bash

# Trabalho G2 Linguagens Automação
# Robson Gonçalves Larissa Pereira e Jessica Paralta
# 30/06/2016


# Menu principal, escolha do exercicio(módulo)
sistema(){

	touch /tmp/pastas.txt /tmp/listagem.txt /tmp/ip.txt /tmp/porta.txt /tmp/logmonitoramento.txt
	menuprincipal=$( dialog \
		--stdout \
		--title 'Trabalho G2' \
		--menu 'Escolha o módulo:' 0 0 0 \
		1 'Gerenciamento de usuarios'\
		2 'Monitoramento de sistemas e servicos'\
		3 'Efetuar backup'\
		4 'Verificar Rede'\
		0 'Sair')
	
	case $menuprincipal in
		1)usuarios
		;;
		2)monitoramento
		;;
		3)backup
		;;
		4)rede
		;;		
		0) 
		clear
		exit
	esac
}
























# Módulo 2.1 Gerencimento usuarios
usuarios(){
# Chama a função que exibe o menu de usuarios
	menuusuarios
}



		
menuusuarios(){	''
# Cria a tela de dialog com as opções disponiveis para o módulo de usuarios
	menuusuarios=$( dialog \
		--backtitle "Gerenciamento de usuários" \
		--stdout \
		--title 'Gerenciamento de usuários' \
		--menu 'Escolha um opção:' 0 0 0 \
		1 'Criar'\
		2 'Modificar'\
		3 'Excluir'\
		4 'Procurar'\
		5 'Listar'\
		0 'Sair')
	
# Chama a função conforme escolhido pelo usuario 
	case $menuusuarios in
		1)criarusuario
		;;
		2)modificarusuario
		;;
		3)excluirusuario
		;;
		4)procurarusuario
		;;
		5)listarusuarios
		;;
		0) sistema
	esac 

         		
}













# Função de criação do usuário
criarusuario(){

usuario=$( dialog \
	--backtitle "Gerenciamento de usuários" \
	--stdout \
	--title 'Criar'\
	--inputbox "Digite o nome do usuário:" \
	10 55)
  
# Adiciona usuario
	useradd -m $usuario
	
# Se não ocorreram erros, exibe mensagem de sucesso
	if [ "$?" = "0" ]; 
	then
		dialog \
		--backtitle "Gerenciamento de usuários" \
		--title "Sucesso" \
		--msgbox "Usuário $usuario criado com sucesso." 6 40
		menuusuarios
# Se ocorreram erros, exibe mensagem de erro
	else
		dialog \
		--title "Erro" \
		--msgbox "Erro ao cadastrar novo usuário." 6 40
		menuusuarios
	fi	
}








#Função de alteração do usuario

modificarusuario (){
	busca=$( 
		dialog \
		--backtitle "Gerenciamento de usuários" \
		--stdout \
		--title 'Modificar' \
		--inputbox 'Usuário a ser modificado:' 8 50) \
		
	# Busca o usuario no arquivo passwd	
	grep -R $busca /etc/passwd
		
	if [ "$?" = "0" ];
		then 
	# Se o usuario existir, pede algumas informações pro usuario
			#usuario=$(dialog \
			#	--stdout \
			#	--title "Modificar" \
			#	--inputbox "Informe o nome do usuario:" 0 0)
			
			senha=$(dialog \
				--stdout \
				--insecure \
				--title 'Modificar' \
				--passwordbox 'Informe a senha do usuario: ' 0 0)
		
			ShellName=$(dialog \
				--stdout \
				--title 'Modificar' \
				--radiolist 'Informe o shell do usuario:' \
				0 0 0 \
				"/usr/sbin/nologin" nologin off \
				"/bin/false" 'false' off \
				"/bin/sh" 'sh' on \
				"/bin/ksh" 'ksh' off \
				"/bin/bash" 'bash' off)

	# Altera o comentario de senha, senha e login de shell	
			#usermod -c "$usuario" $busca
			usermod -p $(openssl passwd -1 $senha) $busca
			usermod -s "$ShellName" $busca
				
	# Se não encontrar o usuario apresenta a mensagem
		else if [ "$?" = "1" ]; 
			then
				dialog \
				--backtitle "Gerenciamento de usuários" \
				--title "Modificar" \
				--msgbox "Usuário $busca não encontrado!" 6 40	
				modificarusuario
		fi
	
	fi
	menuusuarios
}













excluirusuario (){

# Pergunta o usuario a ser removido
usuario=$( dialog \
	--backtitle "Gerenciamento de usuários" \
	--stdout \
	--title 'Excluir'\
	--inputbox 'Usuário a ser removido:' 8 50)

# Confirma a exclusão do usuario
	dialog \
	--stdout \
	--title ' Excluir ' --textbox ${logtemp} 0 0 \
	--and-widget \
	--yesno "Confirma a exclusão do usuário $usuario ?" 10 30
	
	if [ "$?" = "0" ];
		then	
# Se confirmar a deleção, remove o usuário

		deluser --remove-home $usuario
		if [ "$?" = "0" ];
		then
			dialog \
			--backtitle "Gerenciamento de usuários" \
			--title "Sucesso" \
			--msgbox "Usuário $usuario removido com sucesso." 6 40
			excluirusuario
		fi
	else
		dialog \
		--backtitle "Gerenciamento de usuários" \
		--title "Erro" \
		--msgbox "Usuário $usuario não foi removido" 6 40
		menuusuarios
	fi
	
}

procurarusuario (){
$?=0
busca=$( dialog \
	--backtitle "Gerenciamento de usuários" \
	--stdout \
	--title 'Procurar' \
	--inputbox 'Usuário a ser localizado:' 8 50) \
	
	if [ "$?" = "1" ];
	then	
# Se o usuario cancelou a busca	
		dialog \
		--backtitle "Gerenciamento de usuários" \
		--title "Cancelado" \
		--msgbox "Localização de usuário encerrado pelo usuário." 6 40
		menuusuarios
	else	
# Faz a busca do usuario
		grep -R $busca /etc/passwd
		if [ "$?" = "0" ];
		then 
# Pega algumas informacoes deste e exibe		
			diretorio_pessoal=$(cat /etc/passwd | grep "$busca" | cut -d ":" -f 6);
			interpretador=$(cat /etc/passwd | grep "$busca" | cut -d ":" -f 7);
			dialog \
			--backtitle "Gerenciamento de usuários" \
			--title "Procurar" \
			--msgbox "Usuário $busca encontrado! \nInformações: \n Usuário: $busca \n Diretório pessoal: $diretorio_pessoal \n Interpretador: $interpretador" 10 60
			procurarusuario
		else if [ "$?" = "1" ]; 
		then
			dialog \
			--backtitle "Gerenciamento de usuários" \
			--title "Procurar" \
			--msgbox "Usuário $busca não foi encontrado!" 6 40	
			menuusuarios
		fi
	fi
fi	
}









listarusuarios(){

# cria o arquivo listagem.txt
ls /home > /tmp/listagem.txt

dialog --menu 'Usuários do Sistema' 0 0 10 $(cat /tmp/listagem.txt | cut -d: -f1,3 | sed 's/$/ o/')
	
	if [ "$?" = "1" ];
	then
		dialog \
		--backtitle "Gerenciamento de usuários" \
		--title "Cancelado" \
		--msgbox "Visualização de usuário cancelada pelo usuário." 6 40
		menuusuarios
	fi
	
	if [ "$?" = "0" ];
	then
		dialog \
		--backtitle "Gerenciamento de usuários" \
		--title "Encerrada" \
		--msgbox "Visualização de usuário encerrado pelo usuário." 6 40
		menuusuarios
	fi
	
}



































# Módulo 2.2 Monitoramento de sistemas e servicos

# Função de monitoramento
monitoramento(){
	menumonitoramento=$(dialog \
	--backtitle 'Monitoramento de sistemas e servicos' \
	--stdout\
	--menu ' Monitoramento' 0 0 0\
               1 ' Monitorar IP '\
               2 ' Monitorar porta'\
               3 ' Monitoramento '\
               4 ' LOG monitoramento '\
               5 ' Sair ')

    case "$menumonitoramento" in
		1)monitoraip
		;;
		2)monitoraporta
		;;
		3)monitoramentosistema
		;;
		4)logmonitoramento
		;;
		5)sistema
    esac
	
}

# Função que insere o ip a ser monitorado
monitoraip(){
	ip=$( dialog \
		--stdout \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--inputbox 'IP a ser monitorado:' \
		10 60);
	
#insere o ip no arquivo ip.txt	
	echo $ip >> /tmp/ip.txt
	if [ $? -eq 0 ];
	then
		( dialog \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--title "Sucesso" \
		--msgbox "O IP $ip foi inserido." \
		10 60 )
	else
		( dialog \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--title "Erro" \
		--msgbox "Erro ao inserir IP." \
		10 60 )
	fi
 
	monitoramento
}





# Função que insere a porta a ser monitorada
monitoraporta(){
	porta=$( dialog \
		--stdout \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--inputbox 'Portas a serem monitoradas: Obs: Inserir no formato T:porta1,porta2,porta2' \
		10 60);
		
# insere a porta no arquivo porta.txt		
	echo $porta > /tmp/porta.txt
	
	if [ $? -eq 0 ];
	then
		( dialog \
		--stdout \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--title "Sucesso" \
		--msgbox "As portas foram inseridas com sucesso." \
		10 60 )
	else
		( dialog \
		--stdout \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--title "Erro" \
		--msgbox "Erro" \
		10 60 )
	fi
	monitoramento
}







# Faz o monitoramento
monitoramentosistema(){
# Obtem as informacoes de porta e ip e cria o arquivo de log.
	portas=`cat /tmp/porta.txt`;		

	$( dialog \
	--backtitle 'Monitoramento de sistemas e servicos' \
	--title "Monitoramento" \
	--msgbox "Para iniciar o monitoramento pressione ENTER e aguarde" \
	10 60 );

# Obtem as informacoes dos pacotes da rede	
	nmap -sU -iL /tmp/ip.txt -p $portas >> /tmp/logmonitoramento.txt
	monitoramento
}






# Funcao de log do monitoramento
logmonitoramento(){
	caminholog="/tmp/logmonitoramento.txt";
	logmonitoramento=`cat /tmp/logmonitoramento.txt`;
	
	if [ $? -eq 0 ];
	then
		dialog \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--title "Monitoramento" \
		--msgbox "{$logmonitoramento}" \
		100 300
	else
		$( dialog \
		--backtitle 'Monitoramento de sistemas e servicos' \
		--title "Monitoramento" \
		--msgbox "Erro nos logs." \
		10 60 );
	fi
	monitoramento
}






















# Módulo 2.3 Realização Backup

backup(){
	menubackup
}
	
menubackup(){	
	menubackupopcoes=$( dialog \
		--stdout \
		--title 'Realizacao de backup' \
		--menu 'Selecione a opção desejada:' 0 0 0 \
		1 'Insercao das pastas para backup' \
		2 'Agendamento' \
		3 'Realizacao backup' \
		4 'Mostrar Logs' \
		0 'Voltar ao sistema')

	case $menubackupopcoes in
		1)inserepasta 
		;;
		2)agendamento
		;;		
		3)opcaobackup
		;;
		4)logsbackup
		;;
		0)sistema
	esac 
}

opcaobackup (){
	back=$( dialog \
                --stdout \
                --title 'Realizacao de backup' \
                --menu 'Selecione a opção desejada:' 0 0 0 \
                1 'Backup Local' \
                2 'Backup entre maquinas' \
                0 'Voltar ao sistema')
          case $back in
            1) backupbase
            ;;
            2) backupentremaquinas
            ;;
            0)sistema
        esac
}

# Insere pastas
inserepasta()
{
pasta=$( dialog \
		--stdout \
		--backtitle 'Realizacao de backup' \
		--inputbox 'Pasta para backup:' \
		10 60);
	
	echo $pasta >> /tmp/pastas.txt
	if [ $? -eq 0 ];
	then
		( dialog \
		--backtitle 'Realizacao de backup' \
		--title "Sucesso" \
		--msgbox "A pasta foi inserida." \
		10 60 )
	else
		( dialog \
		--backtitle 'Realizacao de backup' \
		--title "Erro" \
		--msgbox "Erro ao inserir pasta." \
		10 60 )
	fi
menubackup
}







backupentremaquinas() {

maquina1="10.31.6.149"
maquina2="10.31.7.52"

    maquinas=$( dialog \
                --stdout \
                --title 'Realizacao de backup'\
                --menu 'Selecione a opção desejada:' 0 0 0 \
                1 'Backup da máquina 1 para máquina 2' \
                2 'Backup da máquina 2 para máquina 1' \
                0 'Voltar ao sistema')
          case $maquinas in
            1) 
			#tar -cvzpf bkpstore/backup.tar.gz -T ${maquina1}${pastas} ${maquina2}
			#backupbase ; for i in $(cat $pastas); do rsync -avz $i root@$maquina2:/home/aluno/backups-maquina1 ; done
			#backupbase ; 
			rsync -avz bkpstore/backup.tar.gz root@$maquina1:/home/aluno/backups-maquina1/
			dialog \
			--backtitle "Backup" \
			--title "Backup" \
			--msgbox "Backup efetuado com sucesso." 6 40
			menubackup			
            ;;
            2) 
			#tar -cvzpf bkpstore/backup.tar.gz -T ${maquina2}${pastas} ${maquina1}
			#backupbase ; for i in $(cat $pastas); do rsync -avz root@$maquina2:/$i /home/aluno/backup-maquina2 ; done
			#backupbase ; 
			rsync -avz root@$maquina1:/root/bkpstore/backup.tar.gz /home/aluno/backup-maquina2/
			dialog \
			--backtitle "Backup" \
			--title "Backup" \
			--msgbox "Backup efetuado com sucesso." 6 40
			menubackup			
			#backupbase ; rsync -avz root@$maquina2:/home/reweb/Desktop/ROBSON/Unilasalle/Automacao/Shell/maquina1 $pastas
            ;;
            0)
			sistema
        esac

}







# Função de agendamento do backup 
agendamento(){

#Dialog recebe o caminho destino do backup
    path_destino=`dialog --stdout --title 'Caminho' --inputbox 'Digite o caminho de destino:' 10 40`

#Dialog recebe o caminho origem do backup
    path_origem=`dialog --stdout --title 'Caminho' --inputbox 'Digite o(s) caminho(s) de origem:' 10 40`
	  
#Criará o diretório destino caso não exista
	if [ ! -d $path_destino ] 
	then 
	  mkdir $path_destino #diretório sendo criado
	  echo 'Criado diretório de Destino'
	fi

	m=$(dialog \
	--stdout \
	--inputbox 'Informe o minuto:' 6 40
	);
	h=$(dialog \
	--stdout \
	--inputbox 'Informe a hora:' 6 40
	);
	d=$(dialog \
	--stdout \
	--inputbox 'Informe o dia do mês:' 6 40
	);
	M=$(dialog \
	--stdout \
	--inputbox 'Informe o mês:' 6 40
	);
	s=$(dialog \
	--stdout \
	--inputbox 'Informe o dia da semana:' 6 40
	);
	#mes=$(dialog \
	#--stdout \
	#--inputbox 'Informe o mês:' 6 40
	#);

	#c="backupbase"
	c="tar -czf $path_destino/$file_bkp $path_origem"
	#usuarioLogado=`whoami`;
	
	#crontab -e -u $usuarioLogado
	

	echo $m $h $d $M $s $c > agd
	crontab -< agd

	#echo $minuto
	#echo "\t"
	#echo $hora
	#echo "\t"
	#echo $diaDoMes
	#echo "\t"
	#echo $mes
	#echo "\t"
	#echo $diaDaSemana
	#echo "\t"
	#echo $usuarioLogado
	#echo "\t"
	#echo backupbase
	
	

	if [ $? -eq 0 ];
	then
		cronlist=$(crontab -l)

		dialog \
		--infobox "Processo de backup agendado." \
		--msgbox "{$cronlist}"
		
		12 80;
	else
		dialog \
		--infobox "Erro ao agendar processo de backup" \
		6 40;
	fi
	monitoramento
}




# Realiza o backup
backupbase(){
	mkdir -p bkpstore
	tar Pcvzf bkpstore/backup.tar.gz -T /tmp/pastas.txt

		dialog \
		--backtitle "Backup" \
		--title "Backup" \
		--msgbox "Backup efetuado com sucesso." 6 40
		menubackup


}


logsbackup(){
# exibe as pastas e os arquivos do backup que se encontram no caminho definido para backup
	#tar tvzf bkpstore/backup.tar.gz
	logs=`tar tvzf bkpstore/backup.tar.gz`

	dialog --backtitle 'Logs Backup' --title "Logs Backup" --msgbox "{$logs}" 20 100

	menubackup
}





# Módulo 2.4 Verificar performance do enlace
rede(){
# Chama a função que exibe o menu de rede
	menurede
}




menurede(){	''
# Cria a tela de dialog com as opções disponiveis para o módulo de rede
	menuderede=$( dialog \
		--backtitle "Gerenciamento de rede" \
		--stdout \
		--title 'Gerenciamento de rede' \
		--menu 'Escolha um opção:' 0 0 0 \
		1 'Verifiar trafego'\
		2 'Mostrar IP'\
		3 'Mostrar Gateway'\
		4 'Pingar IP'\
		5 'Traçar rota'\
		0 'Sair')
	
# Chama a função conforme escolhido pelo usuario 
	case $menuderede in
		1)VerificarTrafego
		;;
		2)MostrarIP
		;;
		3)MostrarGateway
		;;
		4)PingarIP
		;;
		5)TracarRota
		;;
		0) sistema
	esac 

         		
}


VerificarTrafego(){
	iperf -t 10 -c 10.31.7.52 > /tmp/trafego
	trafego=$(cat /tmp/trafego)
	if [ $? -eq 0 ];
	then
		dialog \
		--backtitle 'Monitoramento de trafego' \
		--title "Gerenciamento de rede" \
		--msgbox "{$trafego}" \
		100 300
	fi
	menurede
}



MostrarIP(){
	IP=$(ifconfig eth0 | grep "inet addr")
	#IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
	if [ $? -eq 0 ];
	then
		dialog \
		--backtitle 'IP de rede' \
		--title "Gerenciamento de rede" \
		--msgbox "{$IP}" \
		100 300
	fi	
	menurede
}


MostrarGateway(){
	GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')
	if [ $? -eq 0 ];
	then
		dialog \
		--backtitle 'GATEWAY de rede' \
		--title "Gerenciamento de rede" \
		--msgbox "{$GATEWAY}" \
		100 300
	fi		
	#echo $GATEWAY
	menurede
}


PingarIP(){
	ipdestino="8.8.8.8"
	ping -c 4 $ipdestino | tee ~/ping.log
	menurede
}

TracarRota(){
	mtr --interval 5 $destino
	menurede
}



# Inicio do programa, chamada da função sistema
sistema


