#!/usr/bin/env bats
# Tests for @tsv_extractor Python function/generator decorator
. "$BATS_TEST_DIRNAME"/env.sh >&2

TSVHeader=                         TSV=
TSVHeader+=$'\t''i'                TSV+=$'\t''123'
TSVHeader+=$'\t''float'            TSV+=$'\t''45.678'
TSVHeader+=$'\t''t'                TSV+=$'\t''t'
TSVHeader+=$'\t''f'                TSV+=$'\t''f'
TSVHeader+=$'\t''s'                TSV+=$'\t''foo bar baz'
TSVHeader+=$'\t''empty_str'        TSV+=$'\t'''
TSVHeader+=$'\t''n'                TSV+=$'\t''\N'
TSVHeader+=$'\t''n1'               TSV+=$'\t''NULL'
TSVHeader+=$'\t''n2'               TSV+=$'\t''null'
TSVHeader+=$'\t''n3'               TSV+=$'\t''\\N'
TSVHeader+=$'\t''n4'               TSV+=$'\t''N'
TSVHeader+=$'\t''num_arr'          TSV+=$'\t''{1,2,3}'
TSVHeader+=$'\t''float_arr'        TSV+=$'\t''{1.2,3.45,67.89}'
TSVHeader+=$'\t''text_arr'         TSV+=$'\t''{easy,123,abc,"two words"}'
TSVHeader+=$'\t''nonprintable'     TSV+=$'\t''{\b,"\f","\n","\r","\t",'$'\x1c'','$'\x1d'',"'$'\x1e'' '$'\x1f''",'$'\x7f''}'
TSVHeader+=$'\t''nonprintable2'    TSV+=$'\t''{"\b\b","\f\f","\n\n","\r\r","\t\t",'$'\x1c'$'\x1c'','$'\x1d'$'\x1d'','$'\x1e'$'\x1e'','$'\x1f'$'\x1f'','$'\x7f'$'\x7f''}'
TSVHeader+=$'\t''nonprintable3'    TSV+=$'\t''{"abc\bdef\bghi","abc\fdef\fghi","\n\n","\r\r","\t\t",'$'\x1c'$'\x1c'','$'\x1d'$'\x1d'','$'\x1e'$'\x1e'','$'\x1f'$'\x1f'','$'\x7f'$'\x7f''}'
TSVHeader+=$'\t''punctuations'     TSV+=$'\t''{.,",",.,"{","}",[,],(,),"\\"","\\\\"}'
TSVHeader+=$'\t''punctuations2'     TSV+=$'\t''{.,",",.,"{{","}}",[[,]],((,)),"\\"","\\\\"}'
TSVHeader+=$'\t''torture_arr'      TSV+=$'\t''{"asdf  qwer\tzxcv\n1234"'
                                        TSV+=',""'
                                        TSV+=',"NULL"'
                                        TSV+=',"null"'
                                        TSV+=',"\\\\N"'
                                        TSV+=',N'
                                        TSV+=',"\\"I'\''m your father,\\" said Darth Vader."'
                                        TSV+=',"{\\"csv in a json\\": \\"a,b c,\\\\\\",\\\\\\",\\\\\\"line '\''1'\''\nbogus,NULL,null,\\\\\\\\N,N,line \\\\\\"\\\\\\"2\\\\\\"\\\\\\"\\",  \\"foo\\":123,\n\\"bar\\":45.678, \\"null\\": \\"\\\\\\\\N\\"}"'
                                        TSV+='}'
TSVHeader=${TSVHeader#$'\t'}       TSV=${TSV#$'\t'}  # strip the first delimiter
NastyTSVHeader=$TSVHeader NastyTSV=$TSV

@test "Python @tsv_extractor decorator parser/formatter work correctly" {
    cd "$BATS_TEST_DIRNAME"
    # use an identity UDF to see if the nasty input gets parsed correctly and output correctly
    diff -u \
        <(echo "$NastyTSV"                                         | tr '\t' '\n') \
        <(echo "$NastyTSV" | deepdive env python ./identity_udf.py | tr '\t' '\n') \
        #
}

# TODO also cross validate in another format (like JSON) to catch errors made on both ends
