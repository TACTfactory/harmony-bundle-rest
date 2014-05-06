package com.tactfactory.harmony.test.management.entity;

import java.util.ArrayList;

import com.tactfactory.harmony.annotation.Column;
import com.tactfactory.harmony.annotation.Entity;
import com.tactfactory.harmony.annotation.GeneratedValue;
import com.tactfactory.harmony.annotation.GeneratedValue.Strategy;
import com.tactfactory.harmony.annotation.Id;
import com.tactfactory.harmony.annotation.OneToMany;
import com.tactfactory.harmony.bundles.rest.annotation.Rest;

@Entity
@Rest
public class Company {

	@Id
	@GeneratedValue(strategy=Strategy.MODE_IDENTITY)
	private int id;
	
	@Column
	private String name;
	
	@OneToMany(mappedBy="company")
	private ArrayList<Person> employees;
}
