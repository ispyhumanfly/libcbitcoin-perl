## This file generated by InlineX::C2XS (version 0.22) using Inline::C (version 0.5)
package CBitcoin::Block;

use CBitcoin::Script;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$CBitcoin::Block::VERSION = '0.01';

DynaLoader::bootstrap CBitcoin::Block $CBitcoin::Block::VERSION;

@CBitcoin::Block::EXPORT = ();
@CBitcoin::Block::EXPORT_OK = ();

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub new {
	return bless({},shift);
}




1;