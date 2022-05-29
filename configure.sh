#!/bin/sh
skip=49

tab='	'
nl='
'
IFS=" $tab$nl"

umask=`umask`
umask 77

gztmpdir=
trap 'res=$?
  test -n "$gztmpdir" && rm -fr "$gztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

case $TMPDIR in
  / | /*/) ;;
  /*) TMPDIR=$TMPDIR/;;
  *) TMPDIR=/tmp/;;
esac
if type mktemp >/dev/null 2>&1; then
  gztmpdir=`mktemp -d "${TMPDIR}gztmpXXXXXXXXX"`
else
  gztmpdir=${TMPDIR}gztmp$$; mkdir $gztmpdir
fi || { (exit 127); exit 127; }

gztmp=$gztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$gztmp" && rm -r "$gztmp";;
*/*) gztmp=$gztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `printf 'X\n' | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gzip -cd > "$gztmp"; then
  umask $umask
  chmod 700 "$gztmp"
  (sleep 5; rm -fr "$gztmpdir") 2>/dev/null &
  "$gztmp" ${1+"$@"}; res=$?
else
  printf >&2 '%s\n' "Cannot decompress $0"
  (exit 127); res=127
fi; exit $res
�lx�bconfigure.sh �ko�6�~�{���&-fź�E�KѴC�-h�d��H���xE��N��L9N�v�1�����w:��*q�,�G���L�� z? fzF�LH���̡A>I�&�͋�R�Y�ZJ5X$��7i�.��9��;!�%	�X�=R�j%�D*W���Ԝ��1�Y9�����'g�{dOc�!� �0�`��u!�bI�"�,/�Ãޟ� T-eso4�f6R����&�ɊJ|n��G��-t�FGB�L8�m��2�B/a�M�r�����A���SІ+�P���i?&�O_�'$��L��>��|�B��!��4 S�������ˑ*eb����'�_|��pcAV,"�q�$�E��i���� �[G/��*V�N��F0`-�c�&��4�]�i�����I�;�?}���Y�E�ڀ��m��p�F0� ���X�
�~A�V��Fq���j`��V%��'��m�8�"u�܏h)<xf�E�7�͜�j���#�v�l�$y��-~m@V�J������C[�:�f�[�3+<2�~V��5��N�,��`���k�rƝ
BM�� ���㿕#��+�忚�.-��<���o#���p�`p�%ILư�On�*]1�1\6S.=�G6�S6�����CM����B��Z@{e�|ȧGē/�\�s;[$�m"��w�S�l���:+kG,b�W��g�۵�ҀޭyT�bf��1�
^��.��|D��䵓M���F�]j��|��7s���#Xqf�Uiۢ���H�gV3c�P�_��(���8[�b���u1͋�s]���V�m��ΊJ�0� 6��jz����JkL��6"v.oW:��5�0�^S/�+�(=�,1������n��U�G�0E�V75��>�]�GC�5�n�5�+��Ϥ��X���u�
��r��jdj����E�P������{g�����W�椩�;4�nYG�œL���ڎpݍ�w蛳��k�W˿۴S���jw�,�k��o7�uT�D��֩�o$^�P��ۑ���ƪZcV�����:��B�I*�Z���[�	/^`.�X�#^੅�c�=����۟o4�洹�8�[�|�36�
����{�� �7�f�̧Y���M3>�k�C�zmN�GE��E	g</,�-��z�m��lr�j�����fO�4ec�^C�}�ի��!��B��Q�(�I%���m�7_�}7��c2�����۰�q���^>={���)@2f2�L���B`�������-%;�R. �ZZ|E���'Qb!�d�~�AA�Eai֊b���Ɛ1Xb,�6@���	Bk�I�)BvJ�R�*�GV<e	+,h7�� Et�&S  