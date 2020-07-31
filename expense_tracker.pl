use strict;
use warnings;

print "\t\tTHIS IS A MONTHLY EXPENDITURE TRACKER\n";
my %monthly_savings;
my $more_month = 'y';
while ($more_month eq 'y'){
	print "Enter the month: ";
	chomp (my $month = <STDIN>);
	print "\n";
	print "Enter your budget for the month $month: ";
	chomp (my $budget = <STDIN>);
	print "\n";
	my $more_sources = 'y';
	my %income_sources;
	my $total_income = 0;
	while ($more_sources eq 'y') {
		print "Enter the name of the source of income: ";
		chomp (my $source = <STDIN>);
		print "\n";
		print "Enter the amount you earn from this source: ";
		chomp (my $inc_amount = <STDIN>);
		print "\n";
		$income_sources{$source} = $inc_amount;
	
		print "Do you have any other income sources? (y/n) ";
		chomp ($more_sources = <STDIN>);
		print "\n";
		$total_income += $inc_amount;
	}

	my $more_exp = 'y';
	my $total_exp = 0;
	my %expenditures;
	while ($more_exp eq 'y') {
		print "Enter the expense description: ";
		chomp (my $exp_desc = <STDIN>);
		print "\n";
		print "Enter how much you spent on $exp_desc: ";
		chomp (my $exp_amount = <STDIN>);
		print "\n";
		$expenditures{$exp_desc} = $exp_amount;
		$total_exp += $exp_amount;
	
		print "Do you have any other expenditures to add for the month? (y/n) ";
		chomp ($more_exp = <STDIN>);
		print "\n";
	}
	
	
	
	$monthly_savings{$month} = $total_income - $total_exp;
	my $overshoot = $total_exp - $budget;
	if ($budget<=$total_exp) {		
		print "You have overshot your budget by $overshoot in the month of $month.";
	}
	else {
		print "Good going! You have spent within your budget this month :)";
	}
	
	print "\nDo you want to enter your details for any more months? (y/n) ";
	chomp ($more_month = <STDIN>);
	
	
}

my $ms = \%monthly_savings;
print "Month \t Savings (in Rs.)\n";
for my $key (keys %$ms) {
	print "$key \t $ms->{$key}";
}






	

