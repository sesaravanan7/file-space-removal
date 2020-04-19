#!/usr/bin/perl
###################################################
# Author: Saravanan S E                           #
# Description: Renaming files from dirctory or    #
#              even single file with options      #
###################################################
use strict;
use warnings;
use Getopt::Long;
no warnings "uninitialized";

my ($path,$file,$d) = "";

#Getting options
GetOptions ("file=s" => \$file, "dir=s" => \$d) or die("Error in command line arguments\n");


#If options not filled then program will exit
unless (defined($file) || defined($d)){
  exit(1);
}


#Renaming single file
if (-f $file && defined($file)){
  $path=$file;
  (my $new_file_name = $path) =~s/\s+/\_/g;
  rename("$path", "$new_file_name") || die ( "Error in renaming" );
  if (-f "$new_file_name"){
    print("File renamed succefully\n");
    print ("$path ==> $new_file_name\n");
  }
}elsif(-d $d && defined($d)){
  #Re-naming files in a directory
  
  my $return_files = &renamefiles($d);
  my $flag = 0;
  
  #Setting flag 0 and printing list of files re-named
  foreach my $files(keys(%{$return_files})){
    if($return_files->{$files} eq "True"){
      print("Files renamed \n"), if($flag==0);
      print "$files\n";
      $flag=1;
    }
  }

  #Setting flag 0 and printing list of files not re-named
  $flag = 0;
  foreach my $files(keys(%{$return_files})){
    if($return_files->{$files} eq "False"){
      print("Files unchanged \n"), if($flag==0);
      print "$files\n";
      $flag=1;
    }
  }
}

#Incase if slash is added at end of the path then we need to remove it
if($path =~/\/$/){
  chop($path);
}

#Function to rename files in a directory
sub renamefiles(){
  my $path = shift;
  my $return_files={};
  #opening and reading directory for renaming files;
  opendir(DIR,$path) || die "Error in opening dir $path\n";
  while( (my $filename = readdir(DIR))) {
    #Looking for files with space
    if ($filename =~/\s+/g){
     (my $new_file_name = $filename) =~s/\s+/\_/g;
     
     #using perl utility for re-naming files
     rename("$path/$filename", "$path/$new_file_name") || die ( "Error in renaming" );
     
    #checking whether files are re-named or not
     if (-f "$path/$new_file_name"){
       $return_files->{$new_file_name}="True";
     }else{
       $return_files->{$new_file_name}="False";
     }
    }
  }
  #Closing directory
  closedir(DIR);

  #returning list of files are re-named and not re-named
  return $return_files;
}
