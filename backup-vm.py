import sys, os, commands, subprocess;
#
# Configuration des Backup
#
path_log="/var/log/auto-vzdump.log";
path_vzdump = "vzdump";
path_dump = "/VMs/dump/";
dump_bw_limit = 50000000;

# Configuration remote (SSH / SCP)
enable_remote_backup = True;
remote_host = "<hyp_distant>"
remote_login = "root"
remote_folder = "/VMs/dump"

# Configuration des backup par VM
config_vm = {
        '103' :{
                'mode' : 'snapshot',
                'compress' : True,
                'max_backup_local' : 1
        }
#	'108' :{
#                'mode' : 'snapshot',
#                'compress' : True,
#                'max_backup_local' : 1
#        }
#
#       '510' :{
#                'mode' : 'snapshot',
#                'compress' : True,
#                'max_backup_local' : 2
#        },
#       '511' :{
#                'mode' : 'snapshot',
#                'compress' : True,
#                'max_backup_local' : 2
#        }


};

#
# Fin de la configuration
#

# Functions
def build_cli_dump( vm_id, vm_options ):
        cli = path_vzdump+" "+vm_id;

        # On set le dossier de backup
        if path_dump :
                cli += " --dumpdir "+path_dump;

        # On set la vitesse de backup
        if dump_bw_limit :
                cli += " --bwlimit "+str(dump_bw_limit);

        # On set le nombre de backup conserver
        if 'max_backup_local' in vm_options.keys() :
                cli += " --maxfiles "+str(vm_options['max_backup_local']);

        # On set le mode de backup utiliser
	# snapshot/suspend/stop
        if 'mode' in vm_options.keys() :
                cli += " --mode "+vm_options['mode'];
        else :
                cli += " --mode suspend";

        # On active ou non la compression
        if 'compress' in vm_options.keys() :
                if vm_options['compress'] :
                        cli += " --compress gzip";
                else :
                        cli += " --compress 0";

        # On ajoute l'option pour clean les dossiers temporaires (/var/log, /tmp, /var/tmp, ...)
        if 'exclude-tmp' in vm_options.keys() :
                if vm_options['exclude-tmp'] :
                        cli += " --stdexcludes 1";
                else :
                        cli += " --stdexcludes 0";

        # On ajoute ou non des excludes path custom
        if 'exclude-path' in vm_options.keys() :
                for path in vm_options['exclude-path']:
                        cli += " --exclude-path "+path;
        return cli

def get_last_backup( vm_id ):
        lastFile = False;
        for files in os.listdir( path_dump ):
                if files.endswith(".gz") or files.endswith(".tgz") or files.endswith(".lzo") :
                        if "vzdump-qemu-"+vm_id in files :
                                lastFile = files
        return lastFile;

def remote_backup( vm_id ):
        backup = get_last_backup( vm_id );
        if backup :
                hostname = commands.getoutput("hostname");
                folder = remote_folder+hostname+"/";
                #cmdName = "ssh "+remote_login+"@"+remote_host+" \"qm list |grep "+vm_id+"|awk {\'print $2\'} \"";
		vm_name = commands.getoutput("qm list |grep "+vm_id+"|awk {'print $2'}");
		log( ">> "+vm_name );
		#log( commands.getoutput(vm_name) );
                # Creation du folder distant
                cmdSsh = "ssh "+remote_login+"@"+remote_host+" \"mkdir -p "+remote_folder+"/"+hostname+"/"+vm_name+"\"";
                log( ">> "+cmdSsh );
                log( commands.getoutput(cmdSsh) );
		paths = remote_folder+"/"+hostname+"/"+vm_name+"/";
		finds = " -type f -printf '%T@\t%p\n' |sort -t $'\t' -g | head -n2 | cut -d $'\t' -f 2- |xargs rm";
		# Delete all file except 2 newest
		log( ">> Nettoyage des backups" );
                cmdDel = subprocess.call(["ssh", ""+remote_login+"@"+remote_host+"", "find "+paths+finds+""]);
                # Copie du backup dans le folder distant
                filename, extension = os.path.splitext( backup );
                # recupere le dernier du get_last_backup : backup
		last_backup = get_last_backup( vm_id );
		cmdScp = "scp "+path_dump+backup+" "+remote_login+"@"+remote_host+":"+path_dump+hostname+"/"+vm_name+"/"+last_backup;
                log( ">> "+cmdScp );
                log( commands.getoutput(cmdScp) );

def log( txt ):
        print txt;
        with open(path_log, "a") as logfile:
                logfile.write( txt +"\n");

# Processing
for vm_id, vm_options in config_vm.items() :
        log( "Backup of VM "+vm_id+" : Started" );
        log( " * Nettoyage des connexions de cette VM" );
        cmdClean ="kill `ps -e | grep 'vzctl enter "+str(vm_id)+"' | awk '{print $1}'`"
        log( ">> " + cmdClean );
        log( " * Commande de Backup" );
        cmd = build_cli_dump( vm_id, vm_options );
        log( ">> " + cmd );
        log( commands.getoutput(cmd) );
        if enable_remote_backup :
                log( " * Copie du backup sur un serveur distant : "+remote_host );
                remote_backup( vm_id );
        log( "Backup of VM "+vm_id+" : Finished" );
