record _recipe_str {
	string type;
	string item1;
	string item2;
	string item3;
	string item4;
};

record _recipe {
	string type;
	item item1;
	int item1_count;
	item item2;
	int item2_count;
	item item3;
	int item3_count;
	item item4;
	int item4_count;
};

_recipe_str [item] concoctions_str;
file_to_map("data/concoctions.txt", concoctions_str);
_recipe [item] concoctions;

string multi_item_regex = "(.*?) \\((\\d+)\\)";

foreach i in $items[]
{
	if (concoctions_str contains i)
	{
		if (concoctions_str[i].type.contains_text("CLIPART"))
		{
			continue;
		}

		_recipe r;
		r.type = concoctions_str[i].type;
		r.item1 = concoctions_str[i].item1.to_item();
		r.item1_count = 1;
		if (r.item1 == $item[none])
		{
			matcher m = create_matcher( multi_item_regex, concoctions_str[i].item1 );
			if ( m.find() )
			{
				r.item1 = group(m,1).to_item();
				r.item1_count = group(m,2).to_int();
			}
		}

		r.item2 = concoctions_str[i].item2.to_item();
		r.item2_count = 1;
		if (r.item2 == $item[none])
		{
			matcher m = create_matcher( multi_item_regex, concoctions_str[i].item2 );
			if ( m.find() )
			{
				r.item2 = group(m,1).to_item();
				r.item2_count = group(m,2).to_int();
			}
		}

		r.item3 = concoctions_str[i].item3.to_item();
		r.item3_count = 1;
		if (r.item3 == $item[none])
		{
			matcher m = create_matcher( multi_item_regex, concoctions_str[i].item3 );
			if ( m.find() )
			{
				r.item3 = group(m,1).to_item();
				r.item3_count = group(m,2).to_int();
			}
		}

		r.item4 = concoctions_str[i].item4.to_item();
		r.item4_count = 1;
		if (r.item4 == $item[none])
		{
			matcher m = create_matcher( multi_item_regex, concoctions_str[i].item4 );
			if ( m.find() )
			{
				r.item4 = group(m,1).to_item();
				r.item4_count = group(m,2).to_int();
			}
		}
		concoctions[i] = r;
	}
}

int[item] checkedCreationItems;
int[item] checkedOptimizedItems;

int mall_cost(item i)
{
	if (historical_age(i) < 7.0)
		return historical_price(i);

	return mall_price(i);
}

boolean is_recipe(item i)
{
	if (concoctions contains i)
		return true;

	return false;
}

int get_component_cost(item i)
{
	int cost = 0;

	if (i == $item[none])
		return cost;

	if (checkedCreationItems contains i)
		return cost;

	checkedCreationItems[i] = 0;

	if (is_recipe(i))
	{
		cost = cost + (get_component_cost(concoctions[i].item1) * concoctions[i].item1_count);
		cost = cost + (get_component_cost(concoctions[i].item2) * concoctions[i].item2_count);
		cost = cost + (get_component_cost(concoctions[i].item3) * concoctions[i].item3_count);
		cost = cost + (get_component_cost(concoctions[i].item4) * concoctions[i].item4_count);
	}

	if (cost == 0)
	{
		cost = mall_cost(i);
	}

	checkedCreationItems[i] = cost;

	return cost;
}

int get_optimized_cost(item i)
{
	int cost = 0;

	if (i == $item[none])
		return cost;

	if (checkedOptimizedItems contains i)
		return checkedOptimizedItems[i];

	checkedOptimizedItems[i] = 0;

	if (i.is_recipe())
	{
		int component_cost = 0;
		component_cost = component_cost + (get_optimized_cost(concoctions[i].item1) * concoctions[i].item1_count);
		component_cost = component_cost + (get_optimized_cost(concoctions[i].item2) * concoctions[i].item2_count);
		component_cost = component_cost + (get_optimized_cost(concoctions[i].item3) * concoctions[i].item3_count);
		component_cost = component_cost + (get_optimized_cost(concoctions[i].item4) * concoctions[i].item4_count);

		int result_cost = mall_cost(i);

		if (component_cost < result_cost)
		{
			//print("The components of " + i + " are cheaper");
			cost = component_cost;
		}
		else
		{
			//print(i + " is cheaper then it's components");
			cost = result_cost;
		}
	}
	else if (i.is_coinmaster_item() && i.seller.is_accessible())
	{
		cost = get_optimized_cost(i.seller.item) * sell_price(i.seller, i);
	}

	if (cost < 0)
	{
		cost = 0;
	}

	if (cost == 0 && npc_price(i) > 0)
	{
		cost = npc_price(i);
	}

	if (cost == 0 || (mall_cost(i) > 0 && mall_cost(i) < cost))
	{
		cost = mall_cost(i);
	}

	if (cost < 0)
	{
		cost = 0;
	}

	checkedOptimizedItems[i] = cost;

	return cost;
}

int get_creation_cost(item i)
{
	int cost = 0;

	if (is_recipe(i))
	{
		cost = cost + (get_component_cost(concoctions[i].item1) * concoctions[i].item1_count);
		cost = cost + (get_component_cost(concoctions[i].item2) * concoctions[i].item2_count);
		cost = cost + (get_component_cost(concoctions[i].item3) * concoctions[i].item3_count);
		cost = cost + (get_component_cost(concoctions[i].item4) * concoctions[i].item4_count);
	}

	checkedCreationItems[i] = cost;

	return cost;
}

void find_cheapest(item i)
{
	int buy_cost = 0;
	if (buy_cost == 0 && npc_price(i) > 0)
	{
		buy_cost = npc_price(i);
	}

	if (buy_cost == 0 || (mall_cost(i) > 0 && mall_cost(i) < buy_cost))
	{
		buy_cost = mall_cost(i);
	}

	int full_creation_cost = get_creation_cost(i);

	int optimized_creation_cost = get_optimized_cost(i);

	print(i);
	print("Cost to buy            : " + buy_cost);
	print("Cost to fully create   : " + full_creation_cost);
	print("Optimized creation cost: " + optimized_creation_cost);

}

void check_cheaper()
{
	foreach i in $items[]
	{
		if (is_recipe(i))
		{
			int buy_cost = 0;
			if (buy_cost == 0 && npc_price(i) > 0)
			{
				buy_cost = npc_price(i);
			}

			if (buy_cost == 0 || (mall_cost(i) > 0 && mall_cost(i) < buy_cost))
			{
				buy_cost = mall_cost(i);
			}

			if (buy_cost < 10000000)
			{
				continue;
			}

			int optimized_creation_cost = get_optimized_cost(i);
			if (optimized_creation_cost < buy_cost)
			{
				print(i);
				print("Cost to buy            : " + buy_cost);
				print("Optimized creation cost: " + optimized_creation_cost);
			}
		}
	}
}

void main(item i)
{
	find_cheapest(i);
}
