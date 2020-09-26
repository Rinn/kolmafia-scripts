boolean colorblind = false;

void main() {
	string url = "https://cheesellc.com/kol/profile.php?u=" + my_name().to_lower_case();
	if (colorblind) {
		url = url + "&colorblind=1";
	}
	string page = visit_url(url, false, true);
	
	page = page.replace_string("\"untamed.gif", "\"https://cheesellc.com/kol/untamed.gif");
	page = page.replace_string("\"ccs.css", "\"https://cheesellc.com/kol/ccs.css");
	page = page.replace_string("\"profile.js", "\"https://cheesellc.com/kol/profile.js");
	page = page.replace_string("\"profile.leaderboard.php", "\"https://cheesellc.com/kol/profile.leaderboard.php");
	page = page.replace_string("\"?u=", "\"https://cheesellc.com/kol/profile.php?u=");

	page = page.replace_string("<a href=\"http", "<a target=\"_blank\" href=\"http");

	write(page);
}