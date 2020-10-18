import <zlib.ash>;
import <creation_cost.ash>;

string fight_regex = '<tr><td>(?:<a href="peevpee\\.php\\?action=log&ff=1&lid=(\\d+)&place=logs&pwd=.*?"><small>\\[view\\]<\\/small><\\/a>)?<td><a href="showplayer\\.php\\?who=(\\d+)">.*?<\\/a>&nbsp;\\((\\d)\\)<\\/td><td>vs<\\/td><td><a href="showplayer\\.php\\?who=(\\d+)">.*?<\\/a>&nbsp;\\((\\d+)\\)<\\/td><td nowrap><small>(.*?)<\\/small><\\/td><td><small>(.*?)<\\/small><\\/td><\\/tr>';
string fame_regex = '(?:(.\\d+) Fame)';
string swagger_regex = '(?:(.\\d+) Swagger)';
string stats_regex = '(?:(.\\d+) Stats)';
string item_stole_regex = '(?:Stole (.*))';
string item_lost_regex = '(?:Lost (.*))';

record pvplog {
    int attacker;
    int defender;
    int attacker_score;
    int defender_score;
    string timestamp;
    int fame;
    int stats;
    int swagger;
    item stole;
    item lost;
    string comment;
};

void stolen_profit(int season)
{
    string filename = "PvPHistory_" + my_name() + "_Season_" + season + ".txt";
    pvplog[int] history;
    vprint("Loading " + filename, 6);
    file_to_map(filename, history);

    int total = 0;
    int count = 0;
    int attacks = 0;
    item expensive =  $item[none];
    foreach i in history
    {
        if (history[i].stole != $item[none])
        {
            vprint(history[i].stole.to_string() + ": " + get_optimized_cost(history[i].stole), 6);
            total += get_optimized_cost(history[i].stole);
            count++;
            if (expensive.get_optimized_cost() < get_optimized_cost(history[i].stole))
            {
                expensive = history[i].stole;
            }
        }
        if (history[i].attacker == my_id().to_int())
        {
            attacks++;
        }
    }

    vprint("You have stolen " + count + " items during " + attacks + " attacks. This is why you're on store ignore lists.", 3);
    vprint("Most Expensive: " + expensive.to_string() + ": " + expensive.get_optimized_cost(), 3);
    vprint("Total Meat Gained: " + total, 3);
}

void lost_profit(int season)
{
    string filename = "PvPHistory_" + my_name() + "_Season_" + season + ".txt";
    pvplog[int] history;
    vprint("Loading " + filename, 6);
    file_to_map(filename, history);

    int total = 0;
    int count = 0;
    int defends = 0;
    item expensive =  $item[none];
    foreach i in history
    {
        if (history[i].lost != $item[none])
        {
            vprint(history[i].lost.to_string() + ": " + get_optimized_cost(history[i].lost), 6);
            total += get_optimized_cost(history[i].lost);
            count++;
            if (expensive.get_optimized_cost() < get_optimized_cost(history[i].lost))
            {
                expensive = history[i].lost;
            }
        }
        if (history[i].attacker != my_id().to_int())
        {
            defends++;
        }
    }

    vprint(count + " items have been stolen from you from " + defends + " defends. Maybe make less enemies?", 3);
    vprint("Most Expensive: " + expensive.to_string() + ": " + expensive.get_optimized_cost(), 3);
    vprint("Total Meat Lost: " + total, 3);
}

pvplog parse_matcher(matcher fight_matcher)
{
    pvplog pending;

    pending.attacker = fight_matcher.group(2).to_int();
    pending.defender = fight_matcher.group(4).to_int();
    pending.attacker_score = fight_matcher.group(3).to_int();
    pending.defender_score = fight_matcher.group(5).to_int();
    pending.timestamp = fight_matcher.group(6);
    pending.comment = fight_matcher.group(7).replace_string("&nbsp;", " ");

    matcher comment_matcher = create_matcher(fame_regex, pending.comment);
    if (comment_matcher.find())
    {
        pending.fame = expression_eval(comment_matcher.group(1)).to_int();
    }

    comment_matcher = create_matcher(swagger_regex, pending.comment);
    if (comment_matcher.find())
    {
        pending.swagger = expression_eval(comment_matcher.group(1)).to_int();
    }

    comment_matcher = create_matcher(stats_regex, pending.comment);
    if (comment_matcher.find())
    {
        pending.stats = expression_eval(comment_matcher.group(1)).to_int();
    }

    comment_matcher = create_matcher(item_stole_regex, pending.comment);
    if (comment_matcher.find())
    {
        pending.stole = comment_matcher.group(1).to_item();
    }

    comment_matcher = create_matcher(item_lost_regex, pending.comment);
    if (comment_matcher.find())
    {
        pending.lost = comment_matcher.group(1).to_item();
    }

    return pending;
}

void update_old_season(int season)
{
    vprint("Processing PvP records for Season " + season + "...", 3);
    string filename = "PvPHistory_" + my_name() + "_Old_Season_" + season + ".txt";
    string page;
    page = visit_url("peevpee.php");
    page = visit_url("peevpee.php?place=logs");
    page = visit_url("peevpee.php?place=logs&mevs=0&oldseason=" + season, false);
    page = visit_url("peevpee.php?place=logs&mevs=0&oldseason=" + season + "&showmore=1", false);
    matcher fight_matcher = create_matcher(fight_regex, page);
    int processed = 0;
    pvplog[int] history;
    int index = -1;
    while (fight_matcher.find())
    {
        history[index] = parse_matcher(fight_matcher);
        index = index -1;
        processed = processed + 1;
    }

    vprint("Found " + processed + " records", "blue", 3);
    if (processed > 0)
    {
        vprint("Saving " + filename, 9);
        map_to_file(history, filename);
    }
}

void update_old_seasons()
{
    string regex = "\"peevpee\.php\?place=logs\&mevs=0\&oldseason=(\\d+)\"";
    string page;
    page = visit_url("peevpee.php");
    page = visit_url("peevpee.php?place=logs");
    matcher m = create_matcher(regex, page);
    while (find(m))
    {
        update_old_season(group(m, 1).to_int());
    }
}

int current_season()
{
    string regex = "<b>Current Season: </b>(\\d+)";
    string page;
    page = visit_url("peevpee.php");
    page = visit_url("peevpee.php?place=rules", false);
    matcher m = create_matcher(regex, page);
    int current = 0;
    while (find(m))
    {
        current = group(m, 1).to_int();
    }
    return current;
}

void update_history()
{
    int season = current_season();
    if (season == 0)
    {
        return;
    }
    string filename = "PvPHistory_" + my_name() + "_Season_" + season + ".txt";
    pvplog[int] history;
    vprint("Loading " + filename, 6);
    file_to_map(filename, history);

    vprint("Processing PvP records for current season " + season + "...", 3);
    string page = visit_url("peevpee.php?place=logs&mevs=0&oldseason=0&showmore=1");

    matcher fight_matcher = create_matcher(fight_regex, page);
    int total = 0;
    int processed = 0;
    while (fight_matcher.find())
    {
        if (fight_matcher.group(1) == "")
        {
            continue;
        }

        total = total + 1;
        int id = fight_matcher.group(1).to_int();

        if (history contains id)
        {
            vprint("ID " + id + " already found in history, skipping", 9);
            continue;
        }

        vprint("ID " + id + " not found in history, processing", 9);

        history[id] = parse_matcher(fight_matcher);
        processed = processed + 1;
    }

    vprint("Found " + processed + " new PvP records (" + total + " parsed)", "blue", 3);
    if (processed > 0)
    {
        vprint("Saving " + filename, 9);
        map_to_file(history, filename);
    }

    stolen_profit(season);
    lost_profit(season);
}

void main()
{
    update_history();
    //update_old_seasons();
}