package com.tactfactory.harmony.test.management.entity;

import com.tactfactory.harmony.annotation.Column;
import com.tactfactory.harmony.annotation.Entity;
import com.tactfactory.harmony.annotation.ManyToOne;
import com.tactfactory.harmony.bundles.rest.annotation.Rest;

@Entity
@Rest
public class Worker extends Person {

	@ManyToOne
	@Column(nullable=true)
	private Manager manager;
	
	
}
